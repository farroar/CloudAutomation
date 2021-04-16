resource "azurerm_subnet" "azfw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.address_prefix}"
}

module "pip_name" {
  source            = "../naming"
  
  name              = "afw"
  org_name          = "${var.org_name}"
  subscription_name = "${var.subscription_name}"
  location          = "${var.location}"
  convention        = "gpcxstandard"
  postfix           = "001"
  type              = "pip"
}

resource "azurerm_public_ip" "azfw_pip" {
  name                = "${module.pip_name.pip}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = "${var.tags}"
}

module "azfw_name" {
  source            = "../naming"
  
  name              = "afw"
  org_name          = "${var.org_name}"
  subscription_name = "${var.subscription_name}"
  location          = "${var.location}"
  convention        = "gpcxstandard"
  type              = "afw"
}

resource "azurerm_firewall" "azfw" {
  name                = "${module.azfw_name.afw}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${azurerm_subnet.azfw_subnet.id}"
    public_ip_address_id = "${azurerm_public_ip.azfw_pip.id}"
  }
  
  tags = "${var.tags}"
}