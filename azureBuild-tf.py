#!/usr/bin/python3 

import sys
from git import Repo
import errno, os, stat, shutil
import optparse
import csv
import json

from azureClass import vnet_object
from tfazureinit import *
from tfazurelz import *

#this is to add color to the text output 
from colorama import Fore, Back, Style, init
init(autoreset=True)

def clone_repo(dir_name):
    REMOTE_URL = "https://*******@dev.azure.com/*******/******.0-Terraform/_git/AzureTerraform"
    target_dir = './modules'

    Repo.clone_from(url=REMOTE_URL, to_path=target_dir, branch=DEV_BRANCH)
    '''
    repo = git.Repo.init('./modules')
    origin = repo.create_remote('origin',REMOTE_URL) 
    origin.fetch()
    origin.pull(origin.refs[0].remote_head)
    '''
    print(f"---- {dir_name} REPO PULLED FROM {DEV_BRANCH}----")

def init_dir(dir_name, top_level=False):

    if top_level:
        #create directory and switch to that directory
        if not os.path.isdir(dir_name):
            os.mkdir(dir_name)
        os.chdir(dir_name)
    else:
        #if the directory already exists, remove it and subdirs to start fresh
        if os.path.isdir(dir_name):
            shutil.rmtree(dir_name, ignore_errors=False, onerror=handleRemoveReadonly)
            #shutil.rmtree(dir_name)
            os.mkdir(dir_name)
            os.chdir(dir_name)
            clone_repo(dir_name)
        else:
            os.mkdir(dir_name)
            os.chdir(dir_name)
            clone_repo(dir_name)

def handleRemoveReadonly(func, path, exc):

    excvalue = exc[1]
    if func in (os.rmdir, os.remove) and excvalue.errno == errno.EACCES:
        os.chmod(path, stat.S_IRWXU| stat.S_IRWXG| stat.S_IRWXO) # 0777
        func(path)
    else:
        raise

def main():

    parser = optparse.OptionParser()
    parser.add_option('-p', '--peer-only', action='store_true', dest='run_peering', help='Only run peering', default=False)
    parser.add_option('-w', '--worksheet', dest='worksheet', help="Worksheet to parse", metavar="FILE")
    parser.add_option('-c', '--credentials', dest='credentials', help="Credentials to parse", metavar="FILE")
    parser.add_option('-b', '--branch', dest='branch', help='Module branch', default="master")
    options, args = parser.parse_args()

    #define source data
    build_worksheet_file = options.worksheet
    credentials_worksheet_file = options.credentials
    global DEV_BRANCH 
    DEV_BRANCH = options.branch

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
    
    #create a service principal dict to allow some of this to be portable
    service_principal = {
        'client_id': CLIENT_ID,
        'tenant_id': TENANT_ID,
        'object_id': OBJECT_ID,
    }

    #parse csv file and build vnet objects for each vnet defined in the worksheet
    #initialize vnets dictionary
    vnets = {}
    with open(build_worksheet_file, mode='r', encoding='utf-8-sig') as f:
        build_env = csv.DictReader(f)
        for col in build_env: 
            resource_group = col['vnetName'] + '-network-rg'
            vnet_prefix_list = col['vnetPrefixes'].split(',')

            if col['bastionPrefix']:
                #this is done so we end up with a list of one item, requried for Terraform 2.19+
                bastion_prefix_list = col['bastionPrefix'].split(',')
            else:
                bastion_prefix_list = ""

            #build the vnet object with the inital values requried of all vnets
            vnets[col['vnetName']] = vnet_object(
                col['vnetName'],
                col['subscriptionId'],
                col['location'],
                resource_group,
                vnet_prefix_list,
                col['orgName'],
                col['lzType'],
                bastion_prefix_list,
                col['azfwPrefix'],
                col['gatewayPrefix'],
                col['gatewayIP'],
                col['securityCenter']
                )
            
            #add subnets
            if col['subnetNames']:
                subnet_name_list = col['subnetNames'].split(',')
                #this is split to have individual values
                subnet_prefix_list = col['subnetPrefixes'].split(',')
                while subnet_name_list:
                    subnet_prefix = subnet_prefix_list.pop(0).lstrip()
                    vnets[col['vnetName']].add_subnet(
                        #this is done so we end up with a list of one item, requried for Terraform 2.19+
                        subnet_prefix.split(','),
                        subnet_name_list.pop(0).lstrip(),
                        'VnetLocal'
                    )

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

    #initialize working top level directory for project
    init_dir(ORG_NAME, True)

    for vnet in vnets:
        #setup state keyvault and storage, returns storage keys
        
        STATEKEY1, STATEKEY2, state_storage_account = azure_state_setup(vnets[vnet], OPS_SUBSCRIPTION)
        state_file_name = vnets[vnet].name+'.terraform.tfstate'

        #set environment variable for stroage key
        os.environ['ARM_ACCESS_KEY'] = STATEKEY1
        #set environment variable for current subscription
        os.environ['ARM_SUBSCRIPTION_ID'] = vnets[vnet].subscriptionId

        #initalize directory and clone repo
        init_dir(vnets[vnet].name)

        #create structures for subscriptions
        main_tf = []
        variables_tf = []

        #load up variables dictionary for current object for the .tfvars file
        tfvars_dict = {
            'location': vnets[vnet].location,
            'org_name': vnets[vnet].orgName,
            'subscription_name': vnets[vnet].name,
            'cidr': vnets[vnet].vnetPrefixes,
            'subscription_id': vnets[vnet].subscriptionId
        }

        #load up the variables list for the variables.tf file
        variables_tf.append(block('variable', 'location', {
        }))
        variables_tf.append(block('variable', 'org_name', {
        }))
        variables_tf.append(block('variable', 'subscription_name', {
        }))
        variables_tf.append(block('variable', 'cidr', {
        }))
        variables_tf.append(block('variable', 'subscription_id', {
        }))

        #if subnets exist, append variable and tfvars
        if vnets[vnet].subnets:
            tfvars_dict['subnets'] = vnets[vnet].subnets
            variables_tf.append(block('variable', 'subnets', {
        }))
            
        #if a test VM is specified, append variable and tfvars
        if vnets[vnet].testVM:
            tfvars_dict['test_vm'] = vnets[vnet].testVM
            variables_tf.append(block('variable', 'test_vm', {}))
        
        #if an AzureBastion is specified, append variable and tfvars
        if vnets[vnet].bastionPrefix:
            tfvars_dict['bastion_prefix'] = vnets[vnet].bastionPrefix
            variables_tf.append(block('variable', 'bastion_prefix', {}))

        #if an AzureFirewall is specified, append variable and tfvars
        if vnets[vnet].azfwPrefix:
            tfvars_dict['azfw_prefix'] = vnets[vnet].azfwPrefix
            variables_tf.append(block('variable', 'azfw_prefix', {}))

        #if an GatewaySubnet is specified, append variable and tfvars
        if vnets[vnet].gatewayPrefix:
            tfvars_dict['gateway_prefix'] = vnets[vnet].gatewayPrefix
            variables_tf.append(block('variable', 'gateway_prefix', {}))

        #if a gateway IP for a firewall or router is specified 
        if vnets[vnet].gatewayIP:
            tfvars_dict['gatewayIP'] = vnets[vnet].gatewayIP
            variables_tf.append(block('variable', 'gatewayIP', {}))
        
        #if an tags are specified, append variable and tfvars
        if vnets[vnet].tags:
            tfvars_dict['tags'] = vnets[vnet].tags
            variables_tf.append(block('variable', 'tags', {}))

        #setup provider and tfstate backend blocks
        main_tf.append(block('provider', 'azurerm', {
            'version': "=2.19.0",
            'subscription_id': "${var.subscription_id}",
            'features': {}
        }))
        
        main_tf.append(block('terraform', 'backend', 'azurerm', {
            'storage_account_name': state_storage_account,
            'container_name': "tfstate",
            'key': state_file_name
        }))
        
        #call landing zone function to create landing zone. Passing in the entire vnet object
        #the lz function will check which type of landing zone it is and return the data
        landingzone_tf = lz(vnets[vnet], service_principal)

        #load data into TF files for each object/diredtory
        with open(f"main.tf.json", "w") as f:
            json.dump(main_tf, f, indent=2)
        with open(f"landingzone.tf.json", "w") as f:
            json.dump(landingzone_tf, f, indent=2)
        with open(f"terraform.tfvars.json", "w") as f:
            json.dump(tfvars_dict, f, indent=2)
        with open(f"variables.tf.json", "w") as f:
            json.dump(variables_tf, f, indent=2)

        #os.chdir(f'{vnets[vnet].name}')
        os.system('terraform init')
        os.system('terraform validate')
        #os.system('terraform apply -auto-approve')
        os.chdir('../')

######################
### Build Peerings ###
######################

    #Create the peering directory for the overlay tf files
    init_dir('peerings')

    #take in all of the peerings in the worksheet, place into a dict
    peerings_dict = {}
    for vnet in vnets:
        peerings_dict[vnets[vnet].name] = vnets[vnet].peers
    
    #create discrete pairs of peers from the dict
    peerings_list = []
    for x in peerings_dict:
        for y in peerings_dict[x]:
            peerings_list.append([x,y])

    #boil down the list to bidirectional peers. If the reverse exists in the list
    #skip it since the reverse would be a repeat from the TF perspective
    #this is a list of lists
    final_peerings_list = []
    for peering_pair in peerings_list:
        reverse_peer = peering_pair[::-1]
        if reverse_peer in final_peerings_list:
            pass
        else:
            final_peerings_list.append(peering_pair)

    #now we need to create a list of unique elements. Need to represent each of the
    #subscriptions involved without duplicates. This gets them all into a list.
    subscription_list = []
    for i in final_peerings_list:
        for x in i:
            subscription_list.append(x)
    
    #converting to a set then back to a list takes care of duplicates
    dedup_subscription_list = list(set(subscription_list))
    #create list for terraform file
    peerings_tf = []
    peerings_main_tf = []
    peerings_variables_tf = []
    routing_tf = []

    peerings_variables_tf.append(block('variable', 'vnet_names', {}))
    peerings_variables_tf.append(block('variable', 'resource_group_names', {}))
    peerings_variables_tf.append(block('variable', 'subscriptions_ids', {}))

    #setup tfstate backend blocks
    peerings_main_tf.append(block('terraform', 'backend', 'azurerm', {
        'storage_account_name': state_storage_account,
        'container_name': "tfstate",
        'key': "peerings.terraform.state"
    }))

    for peering in final_peerings_list:
        peering_name = f'{peering[0]}-to-{peering[1]}-peering'
        peering_sub_ids = []
        peering_sub_ids.append(vnets[peering[0]].subscriptionId)
        peering_sub_ids.append(vnets[peering[1]].subscriptionId)

        resource_group_list = []
        vnet_list = []
        side0_rg_name = f'{vnets[peering[0]].orgName}-{vnets[peering[0]].location}-{vnets[peering[0]].name}-network-rg'
        side1_rg_name = f'{vnets[peering[1]].orgName}-{vnets[peering[1]].location}-{vnets[peering[1]].name}-network-rg'
        side0_vnet_name = f'{vnets[peering[0]].orgName}-{vnets[peering[0]].location}-{vnets[peering[0]].name}-primary-vnet'
        side1_vnet_name = f'{vnets[peering[1]].orgName}-{vnets[peering[1]].location}-{vnets[peering[1]].name}-primary-vnet'
        resource_group_list.append(side0_rg_name)
        resource_group_list.append(side1_rg_name)
        vnet_list.append(side0_vnet_name)
        vnet_list.append(side1_vnet_name)

        peerings_tf.append(block('module', peering_name, {
            'source': "./modules/overlay/peering",
            'vnet_names': vnet_list,
            'resource_group_names': resource_group_list ,
            'subscription_ids': peering_sub_ids,
            'allow_virtual_network_access': True
        }))

        if vnets[peering[0]].name == 'transitHub' or vnets[peering[1]].name == 'transitHub':
            for peer in peering:
                if vnets[peer].name == 'transitHub':
                    transit_hub_subscription_id = vnets[peer].subscriptionId
                    azfw_name = f'{vnets[peer].orgName}-{vnets[peer].location}-{vnets[peer].name}-afw'
                    azfw_resource_group_name = f'{vnets[peer].orgName}-{vnets[peer].location}-{vnets[peer].name}-network-rg'
                else:
                    remote_subscription_id = vnets[peer].subscriptionId
                    remote_route_table_name = f'{vnets[peer].orgName}-{vnets[peer].location}-{vnets[peer].name}-private-route'
                    remote_resource_group_name = f'{vnets[peer].orgName}-{vnets[peer].location}-{vnets[peer].name}-network-rg'

            route_name = peering_name + '-route'
            routing_tf.append(block('module', route_name, {
                'source': "./modules/overlay/routing",
                'transitHub_subscription_id': transit_hub_subscription_id,
                'remote_subscription_id': remote_subscription_id,
                'azfw_name': azfw_name,
                'azfw_resource_group_name': azfw_resource_group_name,
                'remote_resource_group_name': remote_resource_group_name,
                'remote_route_table_name': remote_route_table_name
            }))

    with open(f"peerings.tf.json", "w") as f:
        json.dump(peerings_tf, f, indent=2)
    with open(f"peerings_main.tf.json", "w") as f:
        json.dump(peerings_main_tf, f, indent=2)
    with open(f"routing.tf.json", "w") as f:
        json.dump(routing_tf, f, indent=2)
    #with open(f"variables.tf.json", "w") as f:
        #json.dump(peerings_variables_tf, f, indent=2)
    
    os.system('terraform init')
    os.system('terraform validate')
    #os.system('terraform apply -auto-approve')
    os.chdir('../')

####################
### Build Policy ###
####################

    init_dir('policy')

    policy_tf = []
    policy_main_tf = []
    policy_variables_tf = []

    #setup tf variables file
    policy_variables_tf.append(block('variable', 'organization_name', {}))

    policy_main_tf.append(block('provider', 'azurerm', {
            'version': "=2.19.0",
            'features': {}
        }))
    #setup tfstate backend blocks
    policy_main_tf.append(block('terraform', 'backend', 'azurerm', {
        'storage_account_name': state_storage_account,
        'container_name': "tfstate",
        'key': "policy.terraform.state"
    }))

    policy_tf.append(block('module', 'baseline_policies', {
        'source': './modules/policy/global',
        'org_name': ORG_NAME,
        'create_baseline_policies': "true",
        'create_logging_policies': "true",
        "create_security_policies": "true",
        "create_hipaa_policies": "false",
        "management_group_name": "lekus"
    }))

    with open(f"policy_main.tf.json", "w") as f:
        json.dump(policy_main_tf, f, indent=2)
    with open(f"policy.tf.json", "w") as f:
        json.dump(policy_tf, f, indent=2)

    os.system('terraform init')
    os.system('terraform validate')






######################
######################

    print('\n')
    print(f"The storage account key for tfstate is: {STATEKEY1}")


if __name__ == '__main__':
    main()