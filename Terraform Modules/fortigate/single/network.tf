

#####################################################################
####################### Network #####################################


module "vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = var.vnet_name
  resource_group_name = var.vnet_rg_name
  address_space       = var.vnet_cidr
  subnet_prefixes     = [var.outside_subnet, var.inside_subnet]
  subnet_names        = ["outside-subnet", "inside-subnet"]

  tags = var.tags
}


#####################################################################
####################### Public IPs ##################################

module "pip_name" {
  source            = "../../naming"
  name              = "fgt"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "pip"
}  

resource "azurerm_public_ip" "fgt_pip" {
  name                = module.pip_name.pip
  location            = var.location
  resource_group_name = var.vnet_rg_name
  allocation_method   = "Static"

  tags = var.tags
}

#####################################################################
####################### FortiGate NSGs  #############################

resource "azurerm_network_security_group" "outside_nsg" {
  name                = "fgt-outside-nsg"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "inside_nsg" {
  name                = "fgt-inside-nsg"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_security_rule" "outgoing_outside" {
  name                        = "AllowAllOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.fgt_rg_name
  network_security_group_name = azurerm_network_security_group.outside_nsg.name
}

resource "azurerm_network_security_rule" "outgoing_inside" {
  name                        = "AllowAllOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.fgt_rg_name
  network_security_group_name = azurerm_network_security_group.inside_nsg.name
}

#####################################################################
############### FortiGate Primary Network Interfaces ################

resource "azurerm_network_interface" "fgt_port1" {
  name                = "fgt-nic1"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.outside_subnet, 4)
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.fgt_pip.id
  }

  tags = var.tags
}

resource "azurerm_network_interface" "fgt_port2" {
  name                 = "fgt-nic2"
  location             = var.location
  resource_group_name  = var.fgt_rg_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[1]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.inside_subnet, 4)
  }

  tags = var.tags
}

#####################################################################
####################### NSG Assignment ##############################

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "primary_port1_nsg" {
  depends_on                = [azurerm_network_interface.fgt_port1]
  network_interface_id      = azurerm_network_interface.fgt_port1.id
  network_security_group_id = azurerm_network_security_group.outside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "primary_port2_nsg" {
  depends_on                = [azurerm_network_interface.fgt_port2]
  network_interface_id      = azurerm_network_interface.fgt_port2.id
  network_security_group_id = azurerm_network_security_group.inside_nsg.id
}
