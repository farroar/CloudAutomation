

data "azurerm_subnet" "mgmt_subnet" {
  name                 = var.mgmt_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_subnet" "inside_subnet" {
  name                 = var.inside_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_subnet" "outside_subnet" {
  name                 = var.outside_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}


#####################################################################

resource "azurerm_resource_group" "pa_rg" {
    name     = "${var.org_name}-${var.location}-${var.environment}-pafw-rg"
    location = var.location
}

resource "azurerm_availability_set" "aset" {
    name                         = "pafw-aset"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.pa_rg.name
    platform_fault_domain_count  = 2
    platform_update_domain_count = 5
}

#####################################################################

resource "azurerm_public_ip" "pafw1_mgmt_pip" {
    name                = "pafw1-mgmt-pip"
    location            = var.location
    resource_group_name = azurerm_resource_group.pa_rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_public_ip" "pafw2_mgmt_pip" {
    name                = "pafw2-mgmt-pip"
    location            = var.location
    resource_group_name = azurerm_resource_group.pa_rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_public_ip" "pafw1_outside_pip1" {
    name                = "pafw1-outside-pip01"
    location            = var.location
    resource_group_name = azurerm_resource_group.pa_rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_public_ip" "pafw2_outside_pip1" {
    name                = "pafw2-outside-pip01"
    location            = var.location
    resource_group_name = azurerm_resource_group.pa_rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

#####################################################################
######################### pafw1 nics ################################

resource "azurerm_network_interface" "pafw1_eth0" {
    name                 = "pafw1-eth0-nic"
    resource_group_name  = azurerm_resource_group.pa_rg.name
    location             = var.location
    enable_ip_forwarding = true

    ip_configuration {
      name                          = "ipconfig"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.pafw1_mgmt_pip.id
      subnet_id                     = data.azurerm_subnet.mgmt_subnet.id
    }
  
}

resource "azurerm_network_interface" "pafw1_eth1" {
    name                 = "pafw1-eth1-nic"
    resource_group_name  = azurerm_resource_group.pa_rg.name
    location             = var.location
    enable_ip_forwarding = true

    ip_configuration {
      name                          = "ipconfig"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.pafw1_outside_pip1.id
      subnet_id                     = data.azurerm_subnet.outside_subnet.id
    }
  
}

resource "azurerm_network_interface" "pafw1_eth2" {
    name                 = "pafw1-eth2-nic"
    resource_group_name  = azurerm_resource_group.pa_rg.name
    location             = var.location
    enable_ip_forwarding = true

    ip_configuration {
      name                          = "ipconfig"
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = data.azurerm_subnet.inside_subnet.id
    }
  
}

#####################################################################
######################### pafw2 nics ################################

resource "azurerm_network_interface" "pafw2_eth0" {
    name                 = "pafw2-eth0-nic"
    resource_group_name  = azurerm_resource_group.pa_rg.name
    location             = var.location
    enable_ip_forwarding = true

    ip_configuration {
      name                          = "ipconfig"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.pafw2_mgmt_pip.id
      subnet_id                     = data.azurerm_subnet.mgmt_subnet.id
    }
  
}

resource "azurerm_network_interface" "pafw2_eth1" {
    name                 = "pafw2-eth1-nic"
    resource_group_name  = azurerm_resource_group.pa_rg.name
    location             = var.location
    enable_ip_forwarding = true

    ip_configuration {
      name                          = "ipconfig"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.pafw2_outside_pip1.id
      subnet_id                     = data.azurerm_subnet.outside_subnet.id
    }
  
}

resource "azurerm_network_interface" "pafw2_eth2" {
    name                 = "pafw2-eth2-nic"
    resource_group_name  = azurerm_resource_group.pa_rg.name
    location             = var.location
    enable_ip_forwarding = true

    ip_configuration {
      name                          = "ipconfig"
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = data.azurerm_subnet.inside_subnet.id
    }
  
}

#####################################################################

resource "azurerm_virtual_machine" "pafw01" {
    name                = "${var.org_name}-${var.location}-pafw01"
    location            = var.location
    resource_group_name = azurerm_resource_group.pa_rg.name

    vm_size = var.vm_params.vm_size

    os_profile {
      computer_name = "${var.org_name}-${var.location}-pafw01"
      admin_username = var.vm_params.admin_user
      admin_password = var.vm_params.admin_pass
    }

    storage_image_reference {
      publisher = var.vm_params.publisher
      offer     = var.vm_params.offer
      sku       = var.vm_params.sku
      version   = "latest"
    }

    plan {
      name      = var.vm_params.sku
      product   = var.vm_params.offer
      publisher = var.vm_params.publisher
    }

    storage_os_disk {
      name          = "pafw01OSdisk"
      create_option = "FromImage"
    }

    os_profile_linux_config {
      disable_password_authentication = false
    }

    primary_network_interface_id = azurerm_network_interface.pafw1_eth0.id

    network_interface_ids = [
        azurerm_network_interface.pafw1_eth0.id,
        azurerm_network_interface.pafw1_eth1.id,
        azurerm_network_interface.pafw1_eth2.id
    ]

    availability_set_id = azurerm_availability_set.aset.id
}

#####################################################################

resource "azurerm_virtual_machine" "pafw02" {
    name                = "${var.org_name}-${var.location}-pafw02"
    location            = var.location
    resource_group_name = azurerm_resource_group.pa_rg.name

    vm_size = var.vm_params.vm_size

    os_profile {
      computer_name = "${var.org_name}-${var.location}-pafw02"
      admin_username = var.vm_params.admin_user
      admin_password = var.vm_params.admin_pass
    }

    storage_image_reference {
      publisher = var.vm_params.publisher
      offer     = var.vm_params.offer
      sku       = var.vm_params.sku
      version   = "latest"
    }

    plan {
      name      = var.vm_params.sku
      product   = var.vm_params.offer
      publisher = var.vm_params.publisher
    }

    storage_os_disk {
      name          = "pafw02OSdisk"
      create_option = "FromImage"
    }

    os_profile_linux_config {
      disable_password_authentication = false
    }

    primary_network_interface_id = azurerm_network_interface.pafw2_eth0.id

    network_interface_ids = [
        azurerm_network_interface.pafw2_eth0.id,
        azurerm_network_interface.pafw2_eth1.id,
        azurerm_network_interface.pafw2_eth2.id
    ]

    availability_set_id = azurerm_availability_set.aset.id
}
