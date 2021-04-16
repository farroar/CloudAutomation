resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.subnet_prefix}"
}

resource "azurerm_network_security_group" "default_nsg" {
  name                = "${var.subscription_name}-${var.subnet_name}-default-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "DenyAllOut"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = "${var.tags}"
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.default_nsg.id}"
}

resource "azurerm_subnet_route_table_association" "rt_association" {
  subnet_id      = "${azurerm_subnet.subnet.id}"
  route_table_id = "${var.route_table_id}"
}