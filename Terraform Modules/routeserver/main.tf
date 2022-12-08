resource "azurerm_public_ip" "rserver_public_ip" {
  name                = "rserver-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_virtual_hub" "rserver_vhub" {
    name                = "hub-rserver"
    location            = var.location
    resource_group_name = var.resource_group_name
    sku                 = "Standard"
}

data "azurerm_subnet" "subnet" {
  name                 = "RouteServerSubnet"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_virtual_hub_ip" "name" {
  name                 = "hub-rserver-ipconfig"
  subnet_id            = data.azurerm_subnet.subnet.id
  public_ip_address_id = azurerm_public_ip.rserver_public_ip.id
  virtual_hub_id       = azurerm_virtual_hub.rserver_vhub.id
}