#!/usr/bin/python3 

def block(block_type, *args):
    if args:
        body = args[-1]
        labels = list(args[:-1])
    else:
        body = None
        labels = []

    return block_build(block_type, labels, body)

def block_build(block_type, labels, body):

    if block_type == 'provider':
        inner = labels.pop(-1)
        inner_dict = {inner: body}
        block = {block_type: inner_dict}

        return block

    if block_type == 'resource':
        inner = labels.pop(-1)
        outter = labels.pop(-1)
        inner_dict = {inner: body}
        outter_dict = {outter: inner_dict}
        block = {block_type: outter_dict}

        return block
    
    if block_type == 'module':
        inner = labels.pop(-1)
        inner_dict = {inner: body}
        block = {block_type: inner_dict}

        return block

    if block_type == 'variable':
        inner = labels.pop(-1)
        inner_dict = {inner: body}
        block = {block_type: inner_dict}

        return block

    if block_type == 'terraform':
        inner = labels.pop(-1)
        outter = labels.pop(-1)
        inner_dict = {inner: body}
        outter_dict = {outter: inner_dict}
        block = {block_type: outter_dict}

        return block

    if block_type == 'data':
        inner = labels.pop(-1)
        outter = labels.pop(-1)
        inner_dict = {inner: body}
        outter_dict = {outter: inner_dict}
        block = {block_type: outter_dict}

        return block

def lz(vnet, service_principal):

    if vnet.lzType == "standard_lz":
        tf = standard_lz(vnet, service_principal)
        return tf
    elif vnet.lzType == "transithub_lz":
        tf = transitHub_lz(vnet, service_principal)
        return tf
    elif vnet.lzType == "operations_lz":
        tf = operations_lz(vnet, service_principal)  
        return tf
    elif vnet.lzType == "migration_lz":
        tf = migration_lz(vnet, service_principal)
        return tf
    elif vnet.lzType == "dmz_lz":
        tf = migration_lz(vnet, service_principal)
        return tf
    else:
        return

def standard_lz(vnet, service_principal):
    data_list = []

    data_list.append(block('module', 'rg_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "network",
        'type': "rg",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('resource', 'azurerm_resource_group', 'rg', {
        'name': "${module.rg_name.rg}",
        'location': "${var.location}",
        'tags': "${var.tags}"
    }))
            
    data_list.append(block('module', 'vnet', {
        'source': "./modules/vnet", 
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'cidr': "${var.cidr}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

    data_list.append(block('module', 'keyvault', {
        'source': "./modules/keyvault",
        'location': "${var.location}",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'virtual_network_name': "${module.vnet.vnet_name}",
        'tenant_id': service_principal['tenant_id'],
        'object_id': service_principal['object_id'],
        'tags': "${var.tags}"
    }))

    #create private route table
    data_list.append(block('module', 'priv_rt_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "private",
        'type': "route",
        'convention': "gpcxstandard"
    }))

    if vnet.gatewayIP:
        data_list.append(block('module', 'private_route_table', {
            'source': "./modules/routetables/create",
            'route_table_name': "${module.priv_rt_name.route}",
            'location': "${var.location}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'tags': "${var.tags}",
            'add_default': "true",
            'gateway_ip': "${var.gatewayIP}"
        }))
    else:
        data_list.append(block('module', 'private_route_table', {
            'source': "./modules/routetables/create",
            'route_table_name': "${module.priv_rt_name.route}",
            'location': "${var.location}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'tags': "${var.tags}"
        }))


    #create subnets, assign to route table created
    #initialize index for subnets
    i = 0
    for subnet in vnet.subnets:
        subnet_prefix = '${var.subnets['+str(i)+']["addressPrefix"]}'
        subnet_name = '${var.subnets['+str(i)+']["name"]}-subnet'
        data_list.append(block('module', subnet['name']+'-subnet', {
            'source': "./modules/lzsubnet",
            'location': "${var.location}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'route_table_id': "${module.private_route_table.route_table_id}",
            'subnet_name': subnet_name,
            'subnet_prefix': subnet_prefix,
            'virtual_network_name': "${module.vnet.vnet_name}",
            'subscription_name': "${var.subscription_name}",
            'tags': "${var.tags}"
        }))
        i += 1

    if vnet.bastionPrefix:
        data_list.append(block('module', 'bastion', {
            'source': "./modules/bastion",
            'location': "${var.location}",
            'org_name': "${var.org_name}",
            'address_prefix': "${var.bastion_prefix}",
            'subscription_name': "${var.subscription_name}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'tags': "${var.tags}"
        }))

    if vnet.gatewayPrefix:
        data_list.append(block('module', 'vpn_gateway', {
            'source': "./modules/vpngateway",
            'location': "${var.location}",
            'address_prefix': "${var.gateway_prefix}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'tags': "${var.tags}"
        }))
    
    #return list of all terraform json configuration
    return data_list

def transitHub_lz(vnet, service_principal):
    data_list = []

    data_list.append(block('module', 'rg_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "network",
        'type': "rg",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('resource', 'azurerm_resource_group', 'rg', {
        'name': "${module.rg_name.rg}",
        'location': "${var.location}",
        'tags': "${var.tags}"
    }))
            
    data_list.append(block('module', 'vnet', {
        'source': "./modules/vnet", 
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'cidr': "${var.cidr}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

        #create private route table
    data_list.append(block('module', 'priv_rt_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "private",
        'type': "route",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('module', 'private_route_table', {
        'source': "./modules/routetables/create",
        'route_table_name': "${module.priv_rt_name.route}",
        'location': "${var.location}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))
    
    if vnet.azfwPrefix:
        data_list.append(block('module', 'azfw', {
            'source': "./modules/azfw", 
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'subscription_name': "${var.subscription_name}",
            'location': "${var.location}",
            'org_name': "${var.org_name}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'address_prefix': "${var.azfw_prefix}",
            'tags': "${var.tags}"
        }))

        data_list.append(block('module', "azfw_app_default_rule", {
            'source': "./modules/azfw/apprule",
            'azure_firewall_name': "${module.azfw.azfw_name}",
            'azure_firewall_rg': "${azurerm_resource_group.rg.name}",
        }))
    
    if vnet.gatewayPrefix:
        data_list.append(block('module', 'vpn_gateway_subnet', {
            'source': "./modules/vpngateway", 
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'address_prefix': "${var.gateway_prefix}",
            'location': "${var.location}",
            'tags': "${var.tags}"
        }))

    if vnet.subnets:
        i = 0
        for subnet in vnet.subnets:
            subnet_prefix = '${var.subnets['+str(i)+']["addressPrefix"]}'
            subnet_name = '${var.subnets['+str(i)+']["name"]}-subnet'
            data_list.append(block('module', subnet['name']+'-subnet', {
                'source': "./modules/lzsubnet",
                'location': "${var.location}",
                'resource_group_name': "${azurerm_resource_group.rg.name}",
                'route_table_id': "${module.private_route_table.route_table_id}",
                'subnet_name': subnet_name,
                'subnet_prefix': subnet_prefix,
                'virtual_network_name': "${module.vnet.vnet_name}",
                'subscription_name': "${var.subscription_name}",
                'tags': "${var.tags}"
            }))
            i += 1

    return data_list

def operations_lz(vnet, service_principal):
    data_list = []

    data_list.append(block('module', 'rg_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "logging",
        'type': "rg",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('resource', 'azurerm_resource_group', 'rg', {
        'name': "${module.rg_name.rg}",
        'location': "${var.location}",
        'tags': "${var.tags}"
    }))

    data_list.append(block('module', 'la_workspace', {
        'source': "./modules/logging/workspace",
        'location': "${var.location}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'org_name': "${var.org_name}",
        'tags': "${var.tags}"
    }))

    data_list.append(block('module', 'la_solutions', {
        'source': "./modules/logging/solutions",
        'location': "${var.location}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'workspace_id': "${module.la_workspace.workspace_id}",
        'workspace_name': "${module.la_workspace.workspace_name}",
    }))

    return data_list

def migration_lz(vnet, service_principal):
    data_list = []

    data_list.append(block('module', 'rg_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "network",
        'type': "rg",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('resource', 'azurerm_resource_group', 'rg', {
        'name': "${module.rg_name.rg}",
        'location': "${var.location}",
        'tags': "${var.tags}"
    }))
            
    data_list.append(block('module', 'vnet', {
        'source': "./modules/vnet", 
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'cidr': "${var.cidr}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

    data_list.append(block('module', 'keyvault', {
        'source': "./modules/keyvault",
        'location': "${var.location}",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'virtual_network_name': "${module.vnet.vnet_name}",
        'tenant_id': service_principal['tenant_id'],
        'object_id': service_principal['object_id'],
        'tags': "${var.tags}"
    }))

    #create private route table
    data_list.append(block('module', 'priv_rt_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "private",
        'type': "route",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('module', 'private_route_table', {
        'source': "./modules/routetables/create",
        'route_table_name': "${module.priv_rt_name.route}",
        'location': "${var.location}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

    #create subnets, assign to route table created
    #initialize index for subnets
    i = 0
    for subnet in vnet.subnets:
        subnet_prefix = '${var.subnets['+str(i)+']["addressPrefix"]}'
        subnet_name = '${var.subnets['+str(i)+']["name"]}-subnet'
        data_list.append(block('module', subnet['name']+'-subnet', {
            'source': "./modules/lzsubnet",
            'location': "${var.location}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'route_table_id': "${module.private_route_table.route_table_id}",
            'subnet_name': subnet_name,
            'subnet_prefix': subnet_prefix,
            'virtual_network_name': "${module.vnet.vnet_name}",
            'subscription_name': "${var.subscription_name}",
            'tags': "${var.tags}"
        }))
        i += 1

    if vnet.bastionPrefix:
        data_list.append(block('module', 'bastion', {
            'source': "./modules/bastion",
            'location': "${var.location}",
            'address_prefix': "${var.bastion_prefix}",
            'subscription_name': "${var.subscription_name}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'resource_group_name': "${azurerm_resource_group.rg.name}"
        }))

    if vnet.gatewayPrefix:
        data_list.append(block('module', 'bastion', {
            'source': "./modules/vpngateway",
            'location': "${var.location}",
            'address_prefix': "${var.gateway_prefix}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'tags': "${var.tags}"
        }))
            
    if vnet.testVM:
        #initialize index for subnets that have a testVM
        i = 0
        for subnet in vnet.testVM:
            subnet_name = '${var.test_vm['+str(i)+']}-subnet'
            data_list.append(block('module', 'testVM', {
                'source': "./modules/testVM",
                'location': "${var.location}",
                'subnet_name': f"{subnet_name}",
                'vnet_name': "${module.vnet.vnet_name}",
                'resource_group_name': "${azurerm_resource_group.rg.name}"
            }))
            i += 1
    '''        
    if azfw_exists:
        #update priate route tables with azfw as next hop
        data_list.append(block('module', 'azfw_addroute', {
            'source': "./modules/addroute",
            'name': "DefaultRoute",
            'next_hop_type': "VirtualAppliance",
            'route_prefix': "0.0.0.0/0",
            'resource_group': "${azurerm_resource_group.rg.name}",
            'route_table_name': "${var.subscription_name}-private-rt",
            'next_hop_ip': "${module.azfw.azfw_privateIP}"
        }))
    '''
    
    #return list of all terraform json configuration
    return data_list

def dmz_lz(vnet):
    data_list = []

    data_list.append(block('module', 'rg_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "network",
        'type': "rg",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('resource', 'azurerm_resource_group', 'rg', {
        'name': "${module.rg_name.rg}",
        'location': "${var.location}",
        'tags': "${var.tags}"
    }))
            
    data_list.append(block('module', 'vnet', {
        'source': "./modules/vnet", 
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'cidr': "${var.cidr}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

    #create private route table
    data_list.append(block('module', 'priv_rt_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "private",
        'type': "route",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('module', 'private_route_table', {
        'source': "./modules/routetables/create",
        'route_table_name': "${module.priv_rt_name.route}",
        'location': "${var.location}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

    #create public route table
    data_list.append(block('module', 'pub_rt_name', {
        'source': "./modules/naming",
        'org_name': "${var.org_name}",
        'subscription_name': "${var.subscription_name}",
        'location': "${var.location}",
        'name': "public",
        'type': "route",
        'convention': "gpcxstandard"
    }))

    data_list.append(block('module', 'public_route_table', {
        'source': "./modules/routetables/create",
        'route_table_name': "${module.pub_rt_name.route}",
        'location': "${var.location}",
        'resource_group_name': "${azurerm_resource_group.rg.name}",
        'tags': "${var.tags}"
    }))

    #create subnets, assign to route table created
    #initialize index for subnets
    i = 0
    for subnet in vnet.subnets:
        subnet_prefix = '${var.subnets['+str(i)+']["addressPrefix"]}'
        subnet_name = '${var.subnets['+str(i)+']["name"]}-subnet'
        data_list.append(block('module', subnet['name']+'-subnet', {
            'source': "./modules/lzsubnet",
            'location': "${var.location}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'route_table_id': "${module.private_route_table.route_table_id}",
            'subnet_name': subnet_name,
            'subnet_prefix': subnet_prefix,
            'virtual_network_name': "${module.vnet.vnet_name}",
            'subscription_name': "${var.subscription_name}",
            'tags': "${var.tags}"
        }))
        i += 1

    if vnet.bastionPrefix:
        data_list.append(block('module', 'bastion', {
            'source': "./modules/bastion",
            'location': "${var.location}",
            'org_name': "${var.org_name}",
            'address_prefix': "${var.bastion_prefix}",
            'subscription_name': "${var.subscription_name}",
            'virtual_network_name': "${module.vnet.vnet_name}",
            'resource_group_name': "${azurerm_resource_group.rg.name}",
            'tags': "${var.tags}"
        }))
     
    
    #return list of all terraform json configuration
    return data_list

