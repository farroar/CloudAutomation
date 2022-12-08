#####################################################################
# Nathan Farrar
# Cloud Architect
#####################################################################

#####################################################################
######################### Initial Parameters ########################
/*
module "lz_rg_name" {
  source            = "./modules/naming"
  name              = "network"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "rg"
}   

resource "azurerm_resource_group" "lz_network_rg" {
  name      = module.lz_rg_name.rg
  location  = var.location
  tags      = var.tags
}

module "pa_rg_name" {
  source            = "./modules/naming"
  name              = "pafw"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "rg"
}   

resource "azurerm_resource_group" "pafw_rg" {
  name      = module.pa_rg_name.rg
  location  = var.location
  tags      = var.tags
}

module "lz_vnet_name" {
  source            = "./modules/naming"
  name              = "transitHub"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "vnet"
} 
*/


#####################################################################

locals {
  subnet_map = { for s in var.subnets: s.name => s }
  subnet_set = toset([for s in var.subnets: s.name])

  bastion_prefix      = (var.vnet.deploy_bastion ? lookup(local.subnet_map["AzureBastionSubnet"], "prefix") : null)
  route_server_prefix = (var.vnet.deploy_route_server ? lookup(local.subnet_map["RouteServerSubnet"], "prefix") : null)
  gateway_prefix      = (var.vnet.deploy_gateway ? lookup(local.subnet_map["GatewaySubnet"], "prefix") : null)
}

#####################################################################

output "bastion_prefix" {
  value = local.bastion_prefix
}
output "gateway" {
  value = local.gateway_prefix
}
output "rserver" {
  value = local.route_server_prefix
}

#####################################################################

resource "azurerm_resource_group" "hub_network_rg" {
  name = "${var.environment_vars.org_name}-${var.environment_vars.location}-${var.environment_vars.environment}-network-rg"
  location = var.environment_vars.location
  #tags = var.tags
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.environment_vars.org_name}-${var.environment_vars.location}-${var.environment_vars.environment}-network-rg"
  location            = azurerm_resource_group.hub_network_rg.location
  resource_group_name = azurerm_resource_group.hub_network_rg.name
  address_space       = [var.vnet.vnet_cidr]
}

resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_set

  name                 = (each.value == "AzureBastionSubnet" || each.value == "RouteServerSubnet" || each.value == 
  "GatewaySubnet" ? each.value : "${each.value}-subnet")
  resource_group_name  = azurerm_resource_group.hub_network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [local.subnet_map[each.value].prefix]
}

module "security_groups" {
  for_each = toset([ for s in var.subnets: s.name if s.nsg])

  source                   = "../modules/nsg"
  name                     = "${each.value}-nsg"
  location                 = var.environment_vars.location
  resource_group_name      = azurerm_resource_group.hub_network_rg.name
  rule_set                 = local.subnet_map[each.value].security_group_rules
  subnet_name              = (each.value == "AzureBastionSubnet" || each.value == "RouteServerSubnet" || each.value == 
  "GatewaySubnet" ? each.value : "${each.value}-subnet")
  vnet_name                = azurerm_virtual_network.hub_vnet.name
  vnet_resource_group_name = azurerm_resource_group.hub_network_rg.name
}

module "deploy_routeserver" {
  count = (var.vnet.deploy_route_server == true ? 1 : 0)

  source               = "../modules/routeserver"
  location             = var.environment_vars.location
  rserver_prefix       = local.route_server_prefix
  resource_group_name  = azurerm_resource_group.hub_network_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
}

module "deploy_bastion" {
  count = (var.vnet.deploy_bastion ? 1 : 0)

  source                   = "../modules/bastion"
  location                 = var.environment_vars.location
  bastion_prefix           = local.bastion_prefix
  resource_group_name      = azurerm_resource_group.hub_network_rg.name
  virtual_network_name     = azurerm_virtual_network.hub_vnet.name
}

module "deploy_gateway" {
  count = (var.vnet.deploy_gateway == true ? 1 : 0)

  source                   = "../modules/gateway"
  gateway_name             = "gateway"
  location                 = var.environment_vars.location
  gateway_prefix           = local.gateway_prefix
  resource_group_name      = azurerm_resource_group.hub_network_rg.name
  virtual_network_name     = azurerm_virtual_network.hub_vnet.name
  vnet_resource_group_name = azurerm_resource_group.hub_network_rg.name
  gateway_type             = var.vnet.gateway.type
  gateway_sku              = var.vnet.gateway.sku
  deploy_active_active     = var.vnet.gateway.active_active
}

module "deploy_paloalto" {
  count = (var.deploy_pa_a_a == true ? 1: 0)

  source = "../modules/paloalto"

  vm_params   = var.vm_params
  location    = var.location
  org_name    = var.org_name
  environment = var.environment

  vnet_resource_group_name = azurerm_resource_group.hub_network_rg.name
  vnet_name                = azurerm_virtual_network.hub_vnet.name
  mgmt_subnet_name         = "mgmt-subnet"
  inside_subnet_name       = "inside-subnet"
  outside_subnet_name      = "outside-subnet"
}