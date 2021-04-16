locals {
  storage_policy_name = "${var.organization_name}-strgsku-policy"
  storage_display_name = "${var.organization_name}-Allowed Storage SKUs"
}

resource "azurerm_policy_definition" "storage_sku_policy" {
  name         = local.storage_policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = local.storage_display_name

  metadata = <<METADATA
    {
    "category": "General"
    }

METADATA


  policy_rule = <<POLICY_RULE
      {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "not": {
              "field": "Microsoft.Storage/storageAccounts/sku.name",
              "in": "[parameters('listOfAllowedSKUs')]"
            }
          }
        ]
      },
      "then": {
        "effect": "Deny"
      }
    }
POLICY_RULE


  parameters = <<PARAMETERS
    {
      "listOfAllowedSKUs": {
        "type": "Array",
        "metadata": {
          "description": "The list of SKUs that can be specified for storage accounts.",
          "displayName": "Allowed SKUs",
          "strongType": "StorageSKUs"
        }
      }
    }
PARAMETERS

}

output "allowed_storagesku_policy_id" {
  value = azurerm_policy_definition.storage_sku_policy.id
}