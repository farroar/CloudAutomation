locals {
  location_policy_name = "${var.organization_name}-location-policy"
  location_display_name = "${var.organization_name}-Allowed deployment locations"
}

resource "azurerm_policy_definition" "locations_policy" {
  name         = local.location_policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = local.location_display_name

  metadata = <<METADATA
    {
    "category": "General"
    }

METADATA


  policy_rule = <<POLICY_RULE
    {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE


  parameters = <<PARAMETERS
    {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "${var.organization_name}-Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS

}

output "allowed_location_policy_id" {
  value = azurerm_policy_definition.locations_policy.id
}