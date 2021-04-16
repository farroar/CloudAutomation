module "fgt_name" {
  source            = "../../naming"
  name              = "fgt"
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "vm"
} 

resource "azurerm_virtual_machine" "fgt_vm" {
  name                         = module.fgt_name.vm
  location                     = var.location
  resource_group_name          = var.fgt_rg_name
  network_interface_ids        = [azurerm_network_interface.fgt_port1.id, azurerm_network_interface.fgt_port2.id]
  primary_network_interface_id = azurerm_network_interface.fgt_port1.id
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
    name              = "fgtosdisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "fgtdatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "fgt"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = data.template_file.fgt.rendered
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

data "template_file" "fgt" {
  template = file(var.bootstrap)
  vars = {
    port1_ip        = cidrhost(var.outside_subnet, 4)
    port1_mask      = cidrnetmask(var.outside_subnet)
    port2_ip        = cidrhost(var.inside_subnet, 4)
    port2_mask      = cidrnetmask(var.inside_subnet)
    defaultgwy      = cidrhost(var.outside_subnet, 1)
    adminsport      = var.admin_port
  }
}
