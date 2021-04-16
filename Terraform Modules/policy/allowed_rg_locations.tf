locals {
  rg_policy_name = "${var.organization_name}-rglocation-policy"
  rg_display_name = "${var.organization_name}-Allowed resource group deployment locations"
}

resource "azurerm_policy_definition" "rg_locations_policy" {
  name         = local.rg_policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = local.rg_display_name

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
            "equals": "Microsoft.Resources/subscriptions/resourceGroups"
          },
          {
            "field": "location",
            "notIn": "[parameters('listOfAllowedLocations')]"
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
POLICY_RULE


  parameters = <<PARAMETERS
    {
      "listOfAllowedLocations": {
        "type": "Array",
        "metadata": {
          "description": "The list of locations that resource groups can be created in.",
          "strongType": "location",
          "displayName": "Allowed locations"
        }
      }
    }
PARAMETERS

}

output "allowed_rg_location_policy_id" {
  value = azurerm_policy_definition.rg_locations_policy.id
}