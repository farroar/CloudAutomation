provider "azurerm" {
  alias           = "transitHub"
  subscription_id = "${var.transitHub_subscription_id}"
}

provider "azurerm" {
  alias           = "sub"
  subscription_id = "${var.remote_subscription_id}"
}

data "azurerm_firewall" "azfw_private_ip" {
  provider            = azurerm.transitHub
  name                = "${var.azfw_name}"
  resource_group_name = "${var.azfw_resource_group_name}"
}

resource "azurerm_route" "route" {
  name                   = "Default-to-azfw"
  resource_group_name    = "${var.remote_resource_group_name}"
  route_table_name       = "${var.remote_route_table_name}"
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "${data.azurerm_firewall.azfw_private_ip.ip_configuration[0].private_ip_address}"
  provider               = azurerm.sub
}