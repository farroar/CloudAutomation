

locals {
  side_a_name = "${var.vnet_names[0]}-to-${var.vnet_names[1]}-peering"
  side_b_name = "${var.vnet_names[1]}-to-${var.vnet_names[0]}-peering"
}

provider "azurerm" {
  alias           = "sub0"
  version         = "=1.44.0"
  subscription_id = "${var.subscription_ids[0]}"
}

provider "azurerm" {
  alias           = "sub1"
  version         = "=1.44.0"
  subscription_id = "${var.subscription_ids[1]}"
}

data "azurerm_virtual_network" "vnet0" {
  provider            = azurerm.sub0
  name                = "${var.vnet_names[0]}"
  resource_group_name = "${var.resource_group_names[0]}"
}

data "azurerm_virtual_network" "vnet1" {
  provider            = azurerm.sub1
  name                = "${var.vnet_names[1]}"
  resource_group_name = "${var.resource_group_names[1]}"
}

resource "azurerm_virtual_network_peering" "vnet_peer_0" {
  name                         = "${local.side_a_name}"
  resource_group_name          = "${var.resource_group_names[0]}"
  virtual_network_name         = "${var.vnet_names[0]}"
  remote_virtual_network_id    = "${data.azurerm_virtual_network.vnet1.id}"
  allow_virtual_network_access = "${var.allow_virtual_network_access}"
  allow_forwarded_traffic      = "${var.allow_forwarded_traffic}"
  use_remote_gateways          = "${var.use_remote_gateways}"
  provider = azurerm.sub0
}

resource "azurerm_virtual_network_peering" "vnet_peer_1" {
  name                         = "${local.side_b_name}"
  resource_group_name          = "${var.resource_group_names[1]}"
  virtual_network_name         = "${var.vnet_names[1]}"
  remote_virtual_network_id    = "${data.azurerm_virtual_network.vnet0.id}"
  allow_virtual_network_access = "${var.allow_virtual_network_access}"
  allow_forwarded_traffic      = "${var.allow_forwarded_traffic}"
  use_remote_gateways          = "${var.use_remote_gateways}"
  provider = azurerm.sub1
}