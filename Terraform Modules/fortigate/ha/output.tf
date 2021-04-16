
output "Cluster_Public_IP" {
  value = azurerm_public_ip.Cluster_PIP.ip_address
}

output "Primary_Public_IP" {
  value = azurerm_public_ip.Primary_MGMT_PIP.ip_address
}


output "Secondary_Public_IP" {
  value = azurerm_public_ip.Secondary_MGMT_PIP.ip_address
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
