/*locals {
    policy_name = "${var.organization_name}-baselinePolicy"
}

resource "azurerm_policy_set_definition" "example" {
  name                = local.policy_name
  policy_type         = "Custom"
  display_name        = "Test Policy Set"
  management_group_id = "azurerm_management_group.management_group.display_name"

  parameters = <<PARAMETERS
    {
        "allowedLocations": {
            "type": "Array",
            "metadata": {
                "description": "The list of allowed locations for resources.",
                "displayName": "Allowed locations",
                "strongType": "location"
            }
        }
    }
PARAMETERS


  policy_definitions = <<POLICY_DEFINITIONS
    [
        {
            "parameters": {
                "allowedLocations": {
                    "value": "[parameters('allowedLocations')]"
                }
            },
            "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/${var.organization_name}-location-policy"
        }
    ]
POLICY_DEFINITIONS

}
*/