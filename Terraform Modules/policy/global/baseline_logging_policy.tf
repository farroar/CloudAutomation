locals {
    logging_initiative_name                 = "${var.org_name}-baselineLoggingInitiative"
    logging_initiative_display_name         = "${var.org_name}-Baseline logging initiative"
}

####################################################################
                    #Initiative
####################################################################

resource "azurerm_policy_set_definition" "logging_baseline" {
    count = var.create_logging_policies ? 1 : 0
    name                  = local.logging_initiative_name
    policy_type           = "Custom"
    display_name          = local.logging_initiative_display_name
    management_group_name = var.management_group_name

    policy_definition_reference { #Diagnostic logs in Azure Data Lake Store should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/057ef27e-665e-4328-8ea3-04b3122bd9fb"
    }
    policy_definition_reference { #Diagnostic logs in Logic Apps should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/34f95f76-5386-4de7-b824-0d8478470c9d"
    }
    policy_definition_reference { #Diagnostic logs in IoT Hub should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/383856f8-de7f-44a2-81fc-e5135b5c2aa4"
    }
    policy_definition_reference { #Diagnostic logs in Batch accounts should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/428256e6-1fac-4f48-a757-df34c2b3336d"
    }
    policy_definition_reference { #Diagnostic logs in Virtual Machine Scale Sets should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/7c1b1214-f927-48bf-8882-84f0af6588b1"
    }
    policy_definition_reference { #Diagnostic logs in Event Hub should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a214f7-d01a-484b-91a9-ed54470c9a6a"
    }
    policy_definition_reference { #Diagnostic logs in Search services should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b4330a05-a843-4bc8-bf9a-cacce50c67f4"
    }
    policy_definition_reference { #Diagnostic logs in App Services should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b607c5de-e7d9-4eee-9e5c-83f1bcee4fa0"
    }
    policy_definition_reference { #Diagnostic logs in Data Lake Analytics should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c95c74d9-38fe-4f0d-af86-0c7d626a315c"
    }
    policy_definition_reference { #Diagnostic logs in Key Vault should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cf820ca0-f99e-4f3e-84fb-66e913812d21"
    }
    policy_definition_reference { #Diagnostic logs in Service Bus should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f8d36e2f-389b-4ee4-898d-21aeb69a0f45"
    }
    policy_definition_reference { #Diagnostic logs in Azure Stream Analytics should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f9be5368-9bf5-4b84-9e0a-7850da98bb46"
    }
    ####################################################################
    policy_definition_reference { #The Log Analytics agent should be installed on virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a70ca396-0a34-413a-88e1-b956c1e683be"
    }
    #policy_definition_reference { #Deploy Log Analytics agent for Linux VMs
    #    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/053d3325-282c-4e5c-b944-24faffd30d77"
    #}
    #policy_definition_reference { #Deploy Log Analytics agent for Windows VMs
    #    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0868462e-646c-4fe3-9ced-a733534b6a2c"
    #}
    policy_definition_reference { #Deploy Dependency agent for Windows virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1c210e94-a481-4beb-95fa-1571b434fb04"
    }
    policy_definition_reference { #Deploy Dependency agent for Linux virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4da21710-ce6f-4e06-8cdb-5cc4c93ffbee"
    }
    policy_definition_reference { #Audit Dependency agent deployment - VM Image (OS) unlisted
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/11ac78e3-31bc-4f0c-8434-37ab963cea07"
    }
    policy_definition_reference { #Audit Log Analytics Agent Deployment - VM Image (OS) unlisted
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/32133ab0-ee4b-4b44-98d6-042180979d50"
    }
}