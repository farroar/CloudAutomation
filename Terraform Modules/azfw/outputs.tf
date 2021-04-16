output "azfw_pip" {
  value = "${azurerm_public_ip.azfw_pip.ip_address}"
}

output "azfw_private_ip" {
  value = "${azurerm_firewall.azfw.ip_configuration[0].private_ip_address}"
}

output "azfw_name" {
    value = azurerm_firewall.azfw.name
}