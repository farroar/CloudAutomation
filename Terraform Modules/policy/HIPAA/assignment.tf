locals {
  scope = (var.scope == "management_group") ? "/providers/Microsoft.Management/managementGroups/${var.management_group_name}" : "/subscriptions/${var.subscription_id}" 
}

resource "azurerm_policy_assignment" "baseline" {
  count                = var.assign_hipaa_policies ? 1 : 0
  name                 = "${var.org_name}-hipaa-assignment"
  scope                = local.scope
  policy_definition_id = var.policy_id
  description          = "${var.org_name} HIPAA Policy Assignment"
  display_name         = "${var.org_name} HIPAA Policy Assignment"
  location             = var.location

  identity {
      type = "SystemAssigned"
  }

  metadata = jsonencode(
      {
          "category": "Custom"
      }
  )
}