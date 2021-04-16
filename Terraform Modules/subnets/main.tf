resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.address_prefix}"
}
/*
resource "azurerm_network_security_group" "default-nsg" {
  name                = "${var.subscription_name}-default-nsg"
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
}
*/
data "azurerm_subnet" "subnet" {
  name                 = "${azurerm_subnet.subnet.name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.resource_group_name}"
}
/*
resource "azurerm_subnet_network_security_group_association" "subnet" {
  subnet_id                 =  "${data.azurerm_subnet.subnet.id}"
  network_security_group_id =  "${azurerm_network_security_group.default-nsg.id}"
}
*/