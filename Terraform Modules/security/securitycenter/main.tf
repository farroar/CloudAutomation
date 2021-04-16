resource "azurerm_security_center_subscription_pricing" "security_center" {
  tier = "Free"
}

resource "azurerm_security_center_contact" "security_center_contact" {
  email = "contact@example.com"
  phone = "+1-555-555-5555"

  alert_notifications = true
  alerts_to_admins    = true
}