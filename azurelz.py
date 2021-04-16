#!/usr/bin/python3 
import os
import random
import string
import time

from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.network import NetworkManagementClient
from msrestazure.azure_exceptions import CloudError

def azure_firewall_deploy(vnet, resoruce_group, network_client):
    fw_name = naming(vnet,'azfw')
    pip_name = vnet.name+'-pip'
    location = vnet.location
    vnet_name = vnet.orgName+'-'+vnet.name+'-vnet'

    #already exists?
    try:
        check = network_client.public_ip_addresses.get(
            resource_group,
            pip_name
        )
        check_value = True
        print(f'Public IP {pip_name} already exists')
    except:
        check_value = False

    #create public IP
    if not check_value:
        pip = network_client.public_ip_addresses.create_or_update(
            resource_group,
            pip_name,
            {
                'location': location,
                'sku': {
                    'name': 'standard'
                },
                'public_ip_allocation_method': 'static',        
            }
        )
        while not pip.done():
            pip_status = pip.status()
            print(pip_status)
            time.sleep(1.5)
    
    pip_info = network_client.public_ip_addresses.get(
        resource_group,
        pip_name
    )
    subnet_info = network_client.subnets.get(
        resource_group,
        vnet_name,
        'AzureFirewallSubnet'
    )

    #check if firewall already exists
    try:
        check_value = network_client.azure_firewalls.get(
            resource_group,
            fw_name
        )
        checK_value = True
        print(f'Firewall {fw_name} already exists')
    except:
        check_value = False

    #deploy firewall if not exist
    if not check_value:
        try:
            azfw = network_client.azure_firewalls.create_or_update(
                resource_group,
                fw_name,
                {
                    'location': 'eastus',
                    'ip_configurations': [{
                        'name': 'ipconfig',
                        'subnet': {
                            'id': subnet_info.id
                        },
                        'public_ip_address': {
                            'id': pip_info.id
                        }
                    }]
                }
            )
        except CloudError as ex:
            print(str(ex))
        
        while not azfw.done():
            fw_status = azfw.status()
            print(f' Azure firewall deployment - {fw_status}')
            time.sleep(1.5)

    azfw_info = network_client.azure_firewalls.get(
        resource_group,
        fw_name
    )

    #return firewall object
    return azfw_info

def random_generator(size=6, chars=string.ascii_lowercase+string.digits):
    return ''.join(random.choice(chars) for x in range(size))

def naming(vnet, type, **kwargs):
    if type == 'rg':
        if 'name' in kwargs:
            name = kwargs.get('name')
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-{name}-rg'
        else:
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-rg'

    if type == 'vnet':
        if 'name' in kwargs:
            name = kwargs.get('name')
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-{name}-vnet'
        else:
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-vnet'

    if type == 'route':
        if 'name' in kwargs:
            name = kwargs.get('name')
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-{name}-route'
        else:
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-route'

    if type == 'kv':
        if 'name' in kwargs:
            name = kwargs.get('name')
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-{name}-kv'
        else:
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-kv'

    if type == 'azfw':
        if 'name' in kwargs:
            name = kwargs.get('name')
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-{name}-azfw'
        else:
            return f'{vnet.orgName}-{vnet.location}-{vnet.name}-azfw'
            
    if type == 'storage':
        random = random_generator()
        if 'name' in kwargs:
            name = kwargs.get('name')
            return f'{name}{random}'
        else:
            return f'{vnet.name}{random}'

def lz(vnet):
    if vnet.lzType == "standard_lz":
        tf = standard_lz(vnet)
        return tf
    elif vnet.lzType == "transithub_lz":
        tf = transitHub_lz(vnet)
        return tf
    elif vnet.lzType == "operations_lz":
        tf = operations_lz(vnet)  
        return tf
    elif vnet.lzType == "migration_lz":
        tf = migration_lz(vnet)
        return tf
    elif vnet.lzType == "dmz_lz":
        tf = migration_lz(vnet)
        return tf
    else:
        return

def standard_lz(vnet):

    #create connections
    CREDENTIALS = ServicePrincipalCredentials(
        client_id = os.environ['ARM_CLIENT_ID'],
        secret = os.environ['ARM_CLIENT_SECRET'],
        tenant = os.environ['ARM_TENANT_ID']
        )

    #clients for current subscription
    resource_client = ResourceManagementClient(CREDENTIALS, vnet.subscriptionId)
    network_client = NetworkManagementClient(CREDENTIALS, vnet.subscriptionId)

    resource_group_name = naming(vnet, 'rg', name='network')
    resource_client.resource_groups.create_or_update(resource_group_name, {'location':vnet.location})

    vnet_name = naming(vnet, 'vnet', name='primary')

    try:
        get_vnet = network_client.virtual_networks.get(
            resource_group_name,
            vnet_name
        )
        vnet_status = True
        print(f'The {vnet_name} VNet already exists')
    except CloudError as ex:
        print(str(ex))
        print(f'The {vnet_name} VNet does not exist, creating.....')
        vnet_status = False

    if not vnet_status:
        try:
            vnet_build = network_client.virtual_networks.create_or_update(
                resource_group_name,
                vnet_name,
                {
                    'location': vnet.location,
                    'address_space': {
                        'address_prefixes': vnet.prefix
                    }
                }
            )
        except CloudError as ex:
            print(str(ex))        

        while not vnet_build.done():
            time.sleep(1.5)
            print(f'vnet creation: {vnet_build.status()}')

    route_table_name = naming(vnet, 'route', name='primary')

    try:
        get_route_table = network_client.route_tables.get(
            resource_group_name,
            route_table_name
        )
        route_table_status = True
        print(f'The {route_table_name} already exists')
    except CloudError as ex:
        print(str(ex))
        print(f'The {route_table_name} does not exist, creating.....')
        route_table_status = False

    if not route_table_status:
        try:
            route_table_build = network_client.route_tables.create_or_update(
                resource_group_name,
                route_table_name,
                {
                    'location': vnet.location
                }
            )
        except CloudError as ex:
            print(str(ex))    

        while not route_table_build.done():
            time.sleep(1.5)
            print(f'route table creation: {route_table_build.status()}')

    route_table = network_client.route_tables.get(
        resource_group_name,
        route_table_name
    )  

    for subnet in vnet.subnets:

        subnet_name = subnet['name'] + '-subnet'
        try:
            get_subnet = network_client.subnets.get(
                resource_group_name,
                vnet_name,
                subnet_name
            )
            subnet_status = True
            print(f'The {subnet_name} subnet in {vnet_name} already exists')
        except CloudError as ex:
            print(str(ex))
            print(f'The {subnet_name} subnet in {vnet_name} does not exist, creating.....')
            subnet_status = False

        if not subnet_status:
            try:
                subnet_name = subnet['name'] + '-subnet'
                subnet_build = network_client.subnets.create_or_update(
                    resource_group_name,
                    vnet_name,
                    subnet_name,
                    {
                        'addressPrefix': subnet['addressPrefix'],
                        'route_table': {
                            'id': route_table.id
                        }
                    }
                )
            except CloudError as ex:
                print(str(ex))    

            while not subnet_build.done():
                time.sleep(1.5)
                print(f'subnet creation: {route_table_build.status()}')

    if vnet.bastionPrefix:
        try:
            get_subnet = network_client.subnets.get(
                resource_group_name,
                vnet_name,
                'AzureBastionSubnet'
            )
            subnet_status = True
            print(f'The AzureBastionSubnet in {vnet_name} already exists')
        except CloudError as ex:
            print(str(ex))
            print(f'The AzureBastionSubnet in {vnet_name} does not exist, creating.....')
            subnet_status = False
        
        if not subnet_status:
            try:
                subnet_build = network_client.subnets.create_or_update(
                    resource_group_name,
                    vnet_name,
                    'AzureBastionSubnet',
                    {
                        'addressPrefix': vnet.bastionPrefix
                    }
                )
            except CloudError as ex:
                print(str(ex))    

            while not subnet_build.done():
                time.sleep(1.5)
                print(f'subnet creation: {subnet_build.status()}')

def transitHub_lz(vnet):
    #create connections
    CREDENTIALS = ServicePrincipalCredentials(
        client_id = os.environ['ARM_CLIENT_ID'],
        secret = os.environ['ARM_CLIENT_SECRET'],
        tenant = os.environ['ARM_TENANT_ID']
        )

    #clients for current subscription
    resource_client = ResourceManagementClient(CREDENTIALS, vnet.subscriptionId)
    network_client = NetworkManagementClient(CREDENTIALS, vnet.subscriptionId)


    resoruce_group_name = naming(vnet, 'rg', name='network')
    resoruce_client.resource_groups.create_or_update(resoruce_group_name, {'location':'eastus'})

    vnet_name = naming(vnet, 'vnet', name='primary')
    try:
        vnet_build = network_client.virtual_networks.create_or_update(
            resource_group,
            vnet_name,
            {
                'location': vnet.location,
                'address_space': {
                    'address_prefixes': vnet.prefix
                }
            }
        )
    except:
        pass

    while not vnet_build.done():
        time.sleep(1.5)
        print(f'vnet creation: {vnet_build.status()}')

    for subnet in vnet.subnets:
        try:
            subnet_name = subnet['name'] + '-subnet'
            subnet_build = network_client.subnets.create_or_update(
                resource_group,
                vnet_name,
                subnet_name,
                {
                    'addressPrefix': subnet['addressPrefix'],
                    'route_table': {
                        'id': route_table.id
                    }
                }
            )
        except:
            pass

        while not subnet_build.done():
            time.sleep(1.5)
            print(f'subnet creation: {route_table_build.status()}')

    if vnet.bastionPrefix:
        try:
            subnet_build = network_client.subnets.create_or_update(
                resource_group,
                vnet_name,
                'AzureBastionSubnet',
                {
                    'addressPrefix': subnet['addressPrefix']
                }
            )
        except:
            pass

        while not subnet_build.done():
            time.sleep(1.5)
            print(f'subnet creation: {route_table_build.status()}')

    if vnet.azfwPrefix:
        try:
            subnet_build = network_client.subnets.create_or_update(
                resource_group,
                vnet_name,
                'AzureFirewallSubnet',
                {
                    'addressPrefix': subnet['addressPrefix']
                }
            )
        except:
            pass

        while not subnet_build.done():
            time.sleep(1.5)
            print(f'subnet creation: {route_table_build.status()}')
        
        azfw = azure_firewall_deploy(vnet, resoruce_group, network_client)