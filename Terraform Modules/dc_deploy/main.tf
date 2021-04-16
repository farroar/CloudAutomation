
####################### VM Deployment ############################

module "vm_rg_name" {
  source            = "../naming"
  name              = var.vm_short_name
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "rg"
}   

resource "azurerm_resource_group" "vm_rg" {
  name      = module.vm_rg_name.rg
  location  = var.location
  tags      = var.tags
}

module "vm_name" {
  source            = "../naming"
  name              = var.vm_short_name
  org_name          = var.org_name
  subscription_name = var.subscription_name
  location          = var.location
  convention        = "gpcxstandard"
  type              = "vm"
} 

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_short_name}-nic1"
  location            = var.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = module.vm_name.vm
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.dc_admin_name
  admin_password      = var.dc_admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  zone = "1"
  timezone = var.timezone


  os_disk {
    name                 = "dc01osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = var.diag_account_uri
  }
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.vm_short_name}-disk1"
  location             = var.location
  resource_group_name  = azurerm_resource_group.vm_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
  zones = [ "1" ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_backup_protected_vm" "backup_vm" {
  resource_group_name = var.backup_rg_name
  recovery_vault_name = var.recovery_vault_name
  source_vm_id        = azurerm_windows_virtual_machine.vm.id
  backup_policy_id    = var.backup_policy_id
}