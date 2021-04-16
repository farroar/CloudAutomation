module "naming_machine" {
  source            = "../naming"
  
  name              = "primary"
  org_name          = "${var.org_name}"
  subscription_name = "${var.subscription_name}"
  location          = "${var.location}"
  convention        = "gpcxstandard"
  type              = "vnet"
}

resource "azurerm_virtual_network" "vnet" {
    name                = "${module.naming_machine.vnet}"
    address_space       = "${var.cidr}"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    tags                = "${var.tags}"
}
/*
resource "azurerm_route_table" "public" {
  name                          = "${var.subscription_name}-public-rt"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  disable_bgp_route_propagation = false
}

resource "azurerm_route_table" "private" {
  name                          = "${var.subscription_name}-private-rt"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  disable_bgp_route_propagation = false
}
*/