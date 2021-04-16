locals {
  vm_policy_name = "${var.organization_name}-vmsku-policy"
  vm_display_name = "${var.organization_name}-Allowed VM SKUs"
}

resource "azurerm_policy_definition" "vm_sku_policy" {
  name         = local.vm_policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = local.vm_display_name

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
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "not": {
              "field": "Microsoft.Compute/virtualMachines/sku.name",
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
          "description": "The list of SKUs that can be specified for virtual machines.",
          "displayName": "Allowed SKUs",
          "strongType": "VMSKUs"
        }
      }
    }
PARAMETERS

}

output "allowed_vmsku_policy_id" {
  value = azurerm_policy_definition.vm_sku_policy.id
}