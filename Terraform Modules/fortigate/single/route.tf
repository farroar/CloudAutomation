module "route_table_name" {
  source            = "../../naming"
  name              = "inside"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "route"
}

resource "azurerm_route_table" "internal_rt" {
  name                = module.route_table_name.route
  location            = var.location
  resource_group_name = var.fgt_rg_name
}

resource "azurerm_route" "default_to_fgt" {  
  name                   = "default"
  resource_group_name    = var.fgt_rg_name
  route_table_name       = azurerm_route_table.internal_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = cidrhost(var.inside_subnet, 4)
}

resource "azurerm_subnet_route_table_association" "internalassociate" {
  subnet_id      = module.vnet.vnet_subnets[1]
  route_table_id = azurerm_route_table.internal_rt.id
}
