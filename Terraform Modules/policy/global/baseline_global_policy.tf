locals {
  baseline_initiative_name                 = "${var.org_name}-baselineInitiative"
  baseline_initiative_display_name         = "${var.org_name}-Baseline policy initiative"
}

####################################################################
                    #Initiative
####################################################################

resource "azurerm_policy_set_definition" "baseline" {
  count = var.create_baseline_policies ? 1 : 0
  name                  = local.baseline_initiative_name
  policy_type           = "Custom"
  display_name          = local.baseline_initiative_display_name
  management_group_name = var.management_group_name

  parameters = jsonencode(
    {
        "listOfAllowedLocations": {
            "type": "Array",
            "metadata": {
                "description": "The list of locations that resources and resource groups can be created in.",
                "strongType": "location",
                "displayName": "Allowed locations"
            }
        },
        "listOfAllowedVMSKUs": {
            "type": "Array",
            "metadata": {
                "description": "The list of locations that resource groups can be created in.",
                "strongType": "VMSKUs",
                "displayName": "Allowed Size SKUs"
            }
        },
        "listOfAllowedStorageSKUs": {
            "type": "Array",
            "metadata": {
              "displayName": "Allowed Storage SKUs",
              "description": "The list of SKUs that can be specified for storage accounts.",
              "strongType": "StorageSKUs"
            }
          },
        "tagName" : {
          "type" : "String",
          "metadata": {
            "displayName": "Tag Name",
            "description": "Name of the tag, such as 'environment'"
        }
      }
    }
)

  policy_definition_reference { #allowed resoruce locations
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    parameters = {
      listOfAllowedLocations = "[parameters('listOfAllowedLocations')]"
    }
  }
  policy_definition_reference { #allowed resource group locations
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
    parameters = {
      listOfAllowedLocations = "[parameters('listOfAllowedLocations')]"
    }
  }
  policy_definition_reference { #allowed VM SKUs
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
    parameters = {
      listOfAllowedSKUs = "[parameters('listOfAllowedVMSKUs')]"
    }
  }
  policy_definition_reference { #deploy network watcher
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a9b99dd8-06c5-4317-8629-9d86a3c6e7d9"
  }
  policy_definition_reference { #allowed storage SKUs
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/7433c107-6db4-4ad1-b57a-a76dce0154a1"
    parameters = {
      listOfAllowedSKUs = "[parameters('listOfAllowedStorageSKUs')]"
    }
  }
    policy_definition_reference { #require the use of tags
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
    parameters = {
      tagName = "[parameters('tagName')]"
    }
  }
}