module "pip_name" {
  source            = "../naming"
  
  org_name          = "${var.org_name}"
  subscription_name = "${var.subscription_name}"
  location          = "${var.location}"
  postfix           = "bastion"
  convention        = "gpcxstandard"
  type              = "pip"
  name              = "bastion"
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "${module.pip_name.pip}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.address_prefix}"
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "${var.virtual_network_name}-bastion"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${azurerm_subnet.bastion_subnet.id}"
    public_ip_address_id = "${azurerm_public_ip.bastion_pip.id}"
  }

  tags = "${var.tags}"
}

