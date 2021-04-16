
output "Public_IP" {
  value = azurerm_public_ip.fgt_pip.ip_address
}

output "Username" {
  value = var.admin_username
}

output "Password" {
  value = var.admin_password
}

output "Admin_Port" {
  value = var.admin_port
}
