resource "azurerm_firewall_application_rule_collection" "example" {
  name                = "WebEgress"
  azure_firewall_name = var.azure_firewall_name
  resource_group_name = var.azure_firewall_rg
  priority            = 100
  action              = "Allow"

  rule {
    name = "InternetEgressWeb"

    source_addresses = var.source_addresses

    target_fqdns = [
      "*",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}
