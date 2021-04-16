locals {
  scope = (var.scope == "management_group") ? "/providers/Microsoft.Management/managementGroups/${var.management_group_name}" : "/subscriptions/${var.subscription_id}" 
}


resource "azurerm_policy_assignment" "baseline" {
  count                = var.assign_baseline_policies ? 1 : 0
  name                 = "${var.org_name}-policy-assignment"
  scope                = local.scope
  policy_definition_id = var.policy_id
  description          = "${var.org_name} Baseline Policy Assignment"
  display_name         = "${var.org_name} Baseline Policy Assignment"
  location             = var.location

  identity {
      type = "SystemAssigned"
  }

  metadata = jsonencode(
      {
          "category": "Custom"
      }
  )

  parameters = jsonencode(
    {
        "listOfAllowedLocations": {
            "value": var.allowed_locations
        },
        "listOfAllowedVMSKUs": {
            "value": var.allowed_vm_skus
        },
        "listOfAllowedStorageSKUs": {
            "value": var.allowed_storage_skus
        },
        "tagName": {
            "value": var.required_tag_name
        }
    }
    )
}