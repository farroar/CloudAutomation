resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.address_prefix}"
}

resource "azurerm_public_ip" "vpngateway_pip" {
  name                = "vpngwateway-pip1"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = "${var.tags}"
}

resource "azurerm_virtual_network_gateway" "example" {
  name                = "test"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.vpngateway_pip.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.gateway_subnet.id}"
  }

  tags = "${var.tags}"
}