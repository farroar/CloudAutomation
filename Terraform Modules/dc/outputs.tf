output "rg_name" {
    value = azurerm_resource_group.vm_rg.name
}

output "vm_id" {
    value = azurerm_windows_virtual_machine.vm.id
}

output "vm_name" {
    value = azurerm_windows_virtual_machine.vm.name
}