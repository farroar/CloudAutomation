#####################################################################
####################### If Custom Image #############################

//not used
/*
resource "azurerm_image" "custom_fgt_image" {
  count               = var.custom ? 1 : 0
  name                = var.custom_image_name
  resource_group_name = var.custom_image_resource_group_name
  location            = var.location
  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.customuri
    size_gb  = 2
  }
}

resource "azurerm_virtual_machine" "customactivefgtvm" {
  count                        = var.custom ? 1 : 0
  name                         = "customactivefgt"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.myterraformgroup.name
  network_interface_ids        = [azurerm_network_interface.activeport1.id, azurerm_network_interface.activeport2.id, azurerm_network_interface.activeport3.id, azurerm_network_interface.activeport4.id]
  secondary_network_interface_id = azurerm_network_interface.activeport1.id
  vm_size                      = var.size

  storage_image_reference {
    id = var.custom ? element(azurerm_image.custom.*.id, 0) : null
  }

  storage_os_disk {
    name              = "osDisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "activedatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "customactivefgt"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.activeFortiGate.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.secondary_blob_endpoint
  }

  tags = var.tags
}
*/
#####################################################################
####################### If Standard Image and fabric SDN ############

resource "azurerm_virtual_machine" "secondary_fgt_vm" {
  count                        = var.fgt_ha_fabric_conn ? 1 : 0
  name                         = "secondaryfgt"
  location                     = var.location
  resource_group_name          = var.fgt_rg_name
  network_interface_ids        = [azurerm_network_interface.secondary_port1.id, azurerm_network_interface.secondary_port2.id, azurerm_network_interface.secondary_port3.id, azurerm_network_interface.secondary_port4.id]
  primary_network_interface_id = azurerm_network_interface.secondary_port1.id
  vm_size                      = var.size

  storage_image_reference {
    publisher = var.custom ? null : var.publisher
    offer     = var.custom ? null : var.fgt_offer
    sku       = var.custom ? null : var.fgt_sku
    version   = var.custom ? null : var.fgt_version
    #id        = var.custom ? element(azurerm_image.custom.*.id, 0) : null
  }

  plan {
    name      = var.fgt_sku
    publisher = var.publisher
    product   = var.fgt_offer
  }

  storage_os_disk {
    name              = "SecondaryFGTOSDisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "secondaryactivedatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgta"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = data.template_file.secondaryFortiGate.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }

  tags = var.tags
}

data "template_file" "secondaryFortiGate" {
  template = file(var.bootstrap-secondary-sdn)
  vars = {
    port1_ip        = cidrhost(var.outside_subnet, 5)
    port1_mask      = cidrnetmask(var.outside_subnet)
    port2_ip        = cidrhost(var.inside_subnet, 5)
    port2_mask      = cidrnetmask(var.inside_subnet)
    port3_ip        = cidrhost(var.ha_subnet, 5)
    port3_mask      = cidrnetmask(var.ha_subnet)
    port4_ip        = cidrhost(var.mgmt_subnet, 5)
    port4_mask      = cidrnetmask(var.mgmt_subnet)
    active_peerip   = cidrhost(var.ha_subnet, 4)
    mgmt_gateway_ip = cidrhost(var.mgmt_subnet, 1)
    defaultgwy      = cidrhost(var.outside_subnet, 1)
    tenant          = var.tenant_id
    subscription    = var.subscription_id
    clientid        = var.fgt_client_id
    clientsecret    = var.fgt_client_secret
    adminsport      = var.admin_port
    rsg             = var.fgt_rg_name
    clusterip       = azurerm_public_ip.Cluster_PIP.name
    routename       = azurerm_route_table.internal_rt.name
  }
}

#####################################################################
####################### If Standard Image and load balancers ############
/*
resource "azurerm_virtual_machine" "fgta_vm" {
  count                        = var.fgt_ha_fabric_conn ? 1 : 0
  name                         = "activefgt"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.myterraformgroup.name
  network_interface_ids        = [azurerm_network_interface.activeport1.id, azurerm_network_interface.activeport2.id, azurerm_network_interface.activeport3.id, azurerm_network_interface.activeport4.id]
  secondary_network_interface_id = azurerm_network_interface.activeport1.id
  vm_size                      = var.size

  storage_image_reference {
    publisher = var.custom ? null : var.publisher
    offer     = var.custom ? null : var.fgtoffer
    sku       = var.custom ? null : var.fgtsku
    version   = var.custom ? null : var.fgtversion
    id        = var.custom ? element(azurerm_image.custom.*.id, 0) : null
  }

  plan {
    name      = var.fgtsku
    publisher = var.publisher
    product   = var.fgtoffer
  }


  storage_os_disk {
    name              = "osDisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "activedatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "activefgt"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data    = data.template_file.activeFortiGate.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.secondary_blob_endpoint
  }

  tags = {
    environment = "Terraform Demo"
  }
}

data "template_file" "activeFortiGate" {
  template = file(var.bootstrap-active)
  vars = {
    port1_ip        = var.activeport1
    port1_mask      = var.activeport1mask
    port2_ip        = var.activeport2
    port2_mask      = var.activeport2mask
    port3_ip        = var.activeport3
    port3_mask      = var.activeport3mask
    port4_ip        = var.activeport4
    port4_mask      = var.activeport4mask
    passive_peerip  = var.passiveport3
    mgmt_gateway_ip = var.port4gateway
    defaultgwy      = var.port1gateway
    tenant          = var.tenant_id
    subscription    = var.subscription_id
    clientid        = var.client_id
    clientsecret    = var.client_secret
    adminsport      = var.adminsport
    rsg             = azurerm_resource_group.myterraformgroup.name
    clusterip       = azurerm_public_ip.ClusterPublicIP.name
    routename       = azurerm_route_table.internal.name
  }
}
*/