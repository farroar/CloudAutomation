

#####################################################################
####################### Network #####################################


module "vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = var.vnet_name
  resource_group_name = var.vnet_rg_name
  address_space       = var.vnet_cidr
  subnet_prefixes     = [var.outside_subnet, var.inside_subnet, var.ha_subnet, var.mgmt_subnet]
  subnet_names        = ["outside-subnet", "inside-subnet", "ha-subnet", "mgmt-subnet"]

  tags = var.tags
}


#####################################################################
####################### Public IPs ##################################

module "cluster_pip_name" {
  source            = "../../naming"
  name              = "fgt-cluster"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "pip"
}  

resource "azurerm_public_ip" "Cluster_PIP" {
  name                = module.cluster_pip_name.pip
  location            = var.location
  resource_group_name = var.vnet_rg_name
  allocation_method   = "Static"

  tags = var.tags
}

module "primary_mgmt_pip_name" {
  source            = "../../naming"
  name              = "fgt-primary-mgmt"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "pip"
} 

resource "azurerm_public_ip" "Primary_MGMT_PIP" {
  name                = module.primary_mgmt_pip_name.pip
  location            = var.location
  resource_group_name = var.vnet_rg_name
  allocation_method   = "Static"

  tags = var.tags
}

module "secondary_mgmt_pip_name" {
  source            = "../../naming"
  name              = "fgt-secondary-mgmt"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "pip"
} 

resource "azurerm_public_ip" "Secondary_MGMT_PIP" {
  name                = module.secondary_mgmt_pip_name.pip
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

resource "azurerm_network_interface" "primary_port1" {
  name                = "fgt-primary-nic1"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.outside_subnet, 4)
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.Cluster_PIP.id
  }

  tags = var.tags
}

resource "azurerm_network_interface" "primary_port2" {
  name                 = "fgt-primary-nic2"
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

resource "azurerm_network_interface" "primary_port3" {
  name                = "fgt-primary-nic3"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[2]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.ha_subnet, 4)
  }

  tags = var.tags
}

resource "azurerm_network_interface" "primary_port4" {
  name                = "fgt-primary-nic4"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[3]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.mgmt_subnet, 4)
    public_ip_address_id          = azurerm_public_ip.Primary_MGMT_PIP.id
  }

  tags = var.tags
}


#####################################################################
####################### NSG Assignment ##############################

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "primary_port1_nsg" {
  depends_on                = [azurerm_network_interface.primary_port1]
  network_interface_id      = azurerm_network_interface.primary_port1.id
  network_security_group_id = azurerm_network_security_group.outside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "primary_port2_nsg" {
  depends_on                = [azurerm_network_interface.primary_port2]
  network_interface_id      = azurerm_network_interface.primary_port2.id
  network_security_group_id = azurerm_network_security_group.inside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "primary_port3_nsg" {
  depends_on                = [azurerm_network_interface.primary_port3]
  network_interface_id      = azurerm_network_interface.primary_port3.id
  network_security_group_id = azurerm_network_security_group.inside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "primary_port4_nsg" {
  depends_on                = [azurerm_network_interface.primary_port4]
  network_interface_id      = azurerm_network_interface.primary_port4.id
  network_security_group_id = azurerm_network_security_group.outside_nsg.id
}




#####################################################################
############# FortiGate Secondary Network Interfaces ################


resource "azurerm_network_interface" "secondary_port1" {
  name                = "fgt-secondary-nic1"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.outside_subnet, 5)
    primary                       = true
  }

  tags = var.tags
}

resource "azurerm_network_interface" "secondary_port2" {
  name                 = "fgt-secondary-nic2"
  location             = var.location
  resource_group_name  = var.fgt_rg_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[1]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.inside_subnet, 5)
  }

  tags = var.tags
}

resource "azurerm_network_interface" "secondary_port3" {
  name                = "fgt-secondary-nic3"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[2]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.ha_subnet, 5)
  }

  tags = var.tags
}

resource "azurerm_network_interface" "secondary_port4" {
  name                = "fgt-secondary-nic4"
  location            = var.location
  resource_group_name = var.fgt_rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.vnet_subnets[3]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.mgmt_subnet, 5)
    public_ip_address_id          = azurerm_public_ip.Secondary_MGMT_PIP.id
  }

  tags = var.tags
}


# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "secondary_port1_nsg" {
  depends_on                = [azurerm_network_interface.secondary_port1]
  network_interface_id      = azurerm_network_interface.secondary_port1.id
  network_security_group_id = azurerm_network_security_group.outside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "secondary_port2_nsg" {
  depends_on                = [azurerm_network_interface.secondary_port2]
  network_interface_id      = azurerm_network_interface.secondary_port2.id
  network_security_group_id = azurerm_network_security_group.inside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "secondary_port3_nsg" {
  depends_on                = [azurerm_network_interface.secondary_port3]
  network_interface_id      = azurerm_network_interface.secondary_port3.id
  network_security_group_id = azurerm_network_security_group.inside_nsg.id
}

resource "azurerm_network_interface_security_group_association" "secondary_port4_nsg" {
  depends_on                = [azurerm_network_interface.secondary_port4]
  network_interface_id      = azurerm_network_interface.secondary_port4.id
  network_security_group_id = azurerm_network_security_group.outside_nsg.id
}


