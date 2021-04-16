#!/usr/bin/python3 
'''
##############################################################################
This script takes a CSV file and builds an Azure environment across multiple 
subscriptions. It uses a Jinja2 template file to create ARM parameter files for
each line of the CSV. It then uses these parameter files against a common
ARM template to build out the environment.

using the -b flag sets the script to build only. It will only create the .json
files and will NOT send to the Azure subscription

Nathan Farrar - 17-Aug-2019
##############################################################################
'''

import sys
import optparse
import os
import csv
import time
import json
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.compute import ComputeManagementClient
from msrestazure.azure_exceptions import CloudError

from azureClass import vnet_object
from azurelz import *

#$options.worksheet = './Azure/azureBuildv3-worksheet.csv'
#$options.credentials = './Azure/azureBuildv3-credentials.csv'

#this is to add color to the text output 
from colorama import Fore, Back, Style, init
init(autoreset=True)

def init_dir(dir_name, top_level=False):

    if top_level:
        #create directory and switch to that directory
        if not os.path.isdir(dir_name):
            os.mkdir(dir_name)
        os.chdir(dir_name)
    else:
        #if the directory already exists, remove it and subdirs to start fresh
        if os.path.isdir(dir_name):
            shutil.rmtree(dir_name)
            os.mkdir(dir_name)
            os.chdir(dir_name)
        else:
            os.mkdir(dir_name)
            os.chdir(dir_name)

def test_vm_deploy(vnet, subnet, network_client, compute_client):
    subnet_name = vnet.name + '-' + subnet + '-subnet'
    vnet_name = vnet.orgName + '-' + vnet.name + '-vnet'
    vm_name = vnet.name + '-testVM'

    #first check if VM already exists
    #try:
     #   exists = compute_client.virtual_machines.get(vnet.resourceGroup, vm_name)
    exists = False
    if not exists:
        subnet_info = network_client.subnets.get(
            vnet.resourceGroup,
            vnet_name,
            subnet_name
        )

        #create VM NIC
        nic_name = vnet.name + 'testVMNIC'
        nic_params = {
            'location': vnet.location,
            'ip_configurations': [{
                'name': 'myIPConfig',
                  'subnet': {
                    'id': subnet_info.id
                }
            }]
        }
        result = network_client.network_interfaces.create_or_update(
            vnet.resourceGroup,
            nic_name,
            nic_params
        )
        nic_info = network_client.network_interfaces.get(
            vnet.resourceGroup,
            nic_name
        )

        #create VM
        vm_params = {
            'location': vnet.location,
            'tags': {
                'deployment': 'autodeploy',
                'environment': vnet.name,
                'description': 'Temporary testing VM'
            },
            'os_profile': {
                'computer_name': vm_name,
                'admin_username': 'testvm',
                'admin_password': 'test12345!'
            },
            'hardware_profile': {
                'vm_size': 'Standard_DS1'
            },
            'storage_profile': {
                'image_reference': {
                    'publisher': 'Canonical',
                    'offer': 'UbuntuServer',
                    'sku': '16.04.0-LTS',
                    'version': 'latest'
                }
            },
            'network_profile': {
                'network_interfaces': [{
                    'id': nic_info.id
                }]
            }
        }
        try:
            vm_result = compute_client.virtual_machines.create_or_update(
                vnet.resourceGroup,
                vm_name,
                vm_params
            )
            while not vm_result.done():
                time.sleep(1.5)
                print(f'Deploying {vm_name} Test VM: {vm_result.status()}')
            print(Fore.GREEN + f' ********** {vm_name} deployed **********')
            private_ip = nic_info.ip_configurations[0].private_ip_address
            return private_ip
        except CloudError as ex:
            print(Fore.RED + str(ex))
        
    else:
        print(Fore.GREEN + 'VM already deployed')
        private_ip = nic_info.ip_configurations[0].private_ip_address
        return private_ip

def main():
    
    parser = optparse.OptionParser()
    parser.add_option('-p', '--peer-only', action='store_true', dest='run_peering', help='Only run peering', default=False)
    parser.add_option('-w', '--worksheet', dest='worksheet', help="Worksheet to parse", metavar="FILE")
    parser.add_option('-c', '--credentials', dest='credentials', help="Credentials to parse", metavar="FILE")
    options, args = parser.parse_args()

    #define source data
    build_worksheet_file = options.worksheet
    credentials_worksheet_file = options.credentials

    ###############
    #### Prime ####
    ###############

    #import credentials
    with open(credentials_worksheet_file, mode='r', encoding='utf-8-sig') as f:
        credentials = csv.DictReader(f)
        for col in credentials:
            CLIENT_ID = col['client_id']
            TENANT_ID = col['tenant_id']
            OBJECT_ID = col['object_id']
            KEY = col['secret']
            OPS_SUBSCRIPTION = col['ops_subscription']
            ORG_NAME = col['orgName']
    
    #place credentials into environment variables
    os.environ['ARM_CLIENT_ID'] = CLIENT_ID
    os.environ['ARM_TENANT_ID'] = TENANT_ID
    os.environ['ARM_OBJECT_ID'] = OBJECT_ID
    os.environ['ARM_CLIENT_SECRET'] = KEY

    #parse csv file and build vnet objects for each vnet defined in the worksheet
    #initialize vnets dictionary
    vnets = {}
    with open(build_worksheet_file, mode='r', encoding='utf-8-sig') as f:
        build_env = csv.DictReader(f)
        for col in build_env: 
            resource_group = col['vnetName'] + '-network-rg'
            vnet_prefix_list = col['vnetPrefixes'].split(',')
            #build the vnet object with the inital values requried of all vnets
            vnets[col['vnetName']] = vnet_object(
                col['vnetName'],
                col['subscriptionId'],
                col['location'],
                resource_group,
                vnet_prefix_list,
                col['orgName'],
                col['lzType'],
                col['bastionPrefix'],
                col['azfwPrefix'],
                col['gatewayPrefix']
                )
            
            #add subnets
            if col['subnetNames']:
                subnet_name_list = col['subnetNames'].split(',')
                subnet_prefix_list = col['subnetPrefixes'].split(',')
                while subnet_name_list:
                    vnets[col['vnetName']].add_subnet(
                        subnet_prefix_list.pop(0).lstrip(),
                        subnet_name_list.pop(0).lstrip(),
                        'VnetLocal')

            #add peers
            if col['peeredWith']:
                peer_list = col['peeredWith'].split(',')
                for x in peer_list:
                    if x: vnets[col['vnetName']].add_peer(x)

            #add test VM list
            if col['deployTestVM']:
                test_vm_subnet = col['deployTestVM'].split(',')
                for x in test_vm_subnet:
                    vnets[col['vnetName']].add_testVM(x)

            #add tags
            if col['tags']:
                vnets[col['vnetName']].add_tags(col['tags'])
    
    ###############
    #### Build ####
    ###############
   
    for vnet in vnets:
        
        lz(vnets[vnet])
    '''
    if not options.build_only and options.run_peering:
        #access each vnet and run peering calls
        for vnet in vnets: 
            local_subId = vnets[vnet].subscriptionId
            network_client = NetworkManagementClient(CREDENTIALS,local_subId)
            local_vnet = vnets[vnet].name
            local_rg = vnets[vnet].resourceGroup
            local_vnet_name = vnets[vnet].orgName+'-'+local_vnet+'-vnet'

            for peer in vnets[vnet].peers:
                peer_name = vnets[peer].name
                org_name = vnets[vnet].orgName
                remote_vnet_name = org_name+'-'+peer_name+'-vnet'
                peering_name = local_vnet+'-to-'+peer_name
                peerSubId = vnets[peer].subscriptionId
                peerRG = vnets[peer].resourceGroup
                remote_vnet_prefix = vnets[peer].prefix
                remote_vnet_id = '/subscriptions/'+vnets[peer].subscriptionId+'/resourceGroups/'+vnets[peer].resourceGroup+'/providers/Microsoft.Network/virtualNetworks/'+org_name+'-'+peer_name+'-vnet'

                try:
                    peering_status = network_client.virtual_network_peerings.get(
                        local_rg,
                        local_vnet_name,
                        peering_name
                    ) 
                    peered = True
                    print(Fore.GREEN + f'The {peering_name} peering already exists')
                    print(peering_status.provisioning_state)
                except CloudError as ex:
                    peered = False
                    print(Fore.YELLOW + str(ex))
                    print(Fore.YELLOW + f'The {peering_name} has not been created, creating.....')

                if not peered:
                    try:
                        async_vnet_peering = network_client.virtual_network_peerings.create_or_update(
                            local_rg,
                            local_vnet_name,
                            peering_name,
                            {
                                "remote_virtual_network": {
                                    "id": remote_vnet_id
                                },
                                'allow_virtual_network_access': True,
                                'allow_forwarded_traffic': True,
                                'remote_address_space': {
                                    'address_prefixes': [remote_vnet_prefix]
                                }
                            }
                        ) 
                        while not async_vnet_peering.done():
                            time.sleep(2)
                            print(f'Peering: {async_vnet_peering.status()}')
                        print(Fore.GREEN + f' ********** {peering_name} peering completed **********')

                    except CloudError as ex:
                        print(Fore.RED + str(ex))

    #deploy azure firewalls
    if not options.build_only and options.azfw_deploy:
        for vnet in vnets:
            vnet_subnets = vnets[vnet].subnets
            for subnet in vnet_subnets:
                if subnet['name'] == 'AzureFirewallSubnet':
                    network_client = NetworkManagementClient(CREDENTIALS, vnets[vnet].subscriptionId)
                    azfw = azure_firewall_deploy(vnets[vnet], network_client)
                    azfw_ip = azfw.ip_configurations[0].private_ip_address
    
    #update routing tables for azure firewall
    if not options.build_only and options.azfw_deploy:
        for vnet in vnets:
            resource_group = vnets[vnet].resourceGroup
            vnet_name = vnets[vnet].name
            rt_private_name = vnet_name + '-privateRouteTable'

            print(Fore.YELLOW + 'Updating routing table entries .....')
            network_client = NetworkManagementClient(CREDENTIALS, vnets[vnet].subscriptionId)
            privateRouteTable_update = network_client.route_tables.create_or_update(
                resource_group,
                rt_private_name,
                {
                    'location': vnets[vnet].location,
                    'routes': [{
                        'address_prefix': '0.0.0.0/0',
                        'next_hop_type': 'VirtualAppliance',
                        'next_hop_ip_address': azfw_ip,
                        'name': 'DefaultToAzureFirewall'
                    }]
                }
            )

    #if test_vm flag is set, create test VM deploy files
    if options.test_vm:
        for vnet in vnets:
            for subnet in vnets[vnet].testVM:
                if subnet:
                    compute_client = ComputeManagementClient(CREDENTIALS, vnets[vnet].subscriptionId)
                    network_client = NetworkManagementClient(CREDENTIALS, vnets[vnet].subscriptionId)
                    result = test_vm_deploy(vnets[vnet], subnet, network_client, compute_client)

    '''

if __name__ == '__main__':
    main()