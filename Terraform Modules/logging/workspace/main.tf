resource "random_integer" "random_number" {
  min     = 1000
  max     = 5000
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.org_name}-la-wksp${random_integer.random_number.result}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  sku                 = "PerGB2018"
  retention_in_days   = 365
  tags                = "${var.tags}"
}