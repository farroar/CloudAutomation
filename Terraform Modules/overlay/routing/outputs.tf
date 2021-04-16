output "firewall_private_ip" {
  value = "${data.azurerm_firewall.azfw_private_ip.ip_configuration[0].private_ip_address}"
}