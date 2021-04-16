locals {
    security_initiative_name                 = "${var.org_name}-baselineSecurityInitiative"
    security_initiative_display_name         = "${var.org_name}-Baseline security initiative"
}

####################################################################
                    #Initiative
####################################################################

resource "azurerm_policy_set_definition" "security_baseline" {
    count = var.create_security_policies ? 1 : 0
    name                  = local.security_initiative_name
    policy_type           = "Custom"
    display_name          = local.security_initiative_display_name
    management_group_name = var.management_group_name

    policy_definition_reference { #Azure Backup should be enabled for Virtual Machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/013e242c-8828-4970-87b3-ab247555486d"
    }
    policy_definition_reference { #Adaptive Network Hardening recommendations should be applied on internet facing virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/08e6af2d-db70-460a-bfe9-d5bd474ba9d6"
    }
    policy_definition_reference { #There should be more than one owner assigned to your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/09024ccc-0c5f-475e-9457-b7c0d9ed487b"
    }
    policy_definition_reference { #Disk encryption should be applied on virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0961003e-5a0a-4549-abde-af6a37f2724d"
    }
    policy_definition_reference { #Key Vault objects should be recoverable
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0b60c0b2-2dc2-4e1c-b5c9-abbed971de53"
    }
    policy_definition_reference { #Managed identity should be used in your Function App
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0da106f2-4ca3-48e8-bc85-c638fe6aea8f"
    }
    policy_definition_reference { #Azure Monitor log profile should collect logs for categories 'write,' 'delete,' and 'action'
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1a4e592a-6a6e-44a5-9814-e36264ca96e7"
    }
    policy_definition_reference { #Vulnerability assessment should be enabled on SQL Managed Instance
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1b7aa243-30e4-4c9e-bca8-d0d3022b634a"
    }
    policy_definition_reference { #Management ports should be closed on your virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/22730e10-96f6-4aac-ad84-9383d35b5917"
    }
    policy_definition_reference { #Only secure connections to your Azure Cache for Redis should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/22bee202-a82f-4305-9a2a-6d7f44d4dedb"
    }
    policy_definition_reference { #Service Bus should use a virtual network service endpoint
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/235359c5-7c52-4b82-9055-01c75cf9f60e"
    }
    policy_definition_reference { #Endpoint protection solution should be installed on virtual machine scale sets
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/26a828e1-e88f-464e-bbb3-c134a282b9de"
    }
    policy_definition_reference { #Managed identity should be used in your Web App
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2b9ad585-36bc-4615-b300-fd4435808332"
    }
    policy_definition_reference { #Unattached disks should be encrypted
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2c89a2e5-7285-40fe-afe0-ae8654b92fb2"
    }
    policy_definition_reference { #Storage accounts should restrict network access
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c"
    }
    policy_definition_reference { #Deploy prerequisites to audit Windows VMs configurations in 'Security Options - Network Security'
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/36e17963-7202-494a-80c3-f508211c826b"
    }
    policy_definition_reference { #Vulnerabilities in security configuration on your virtual machine scale sets should be remediated
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3c735d8a-a4ba-4a3a-b7cf-db7754cf57f4"
    }
    policy_definition_reference { #Secure transfer to storage accounts should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
    }
    policy_definition_reference { #Azure Monitor should collect activity logs from all regions
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/41388f1c-2db0-4c25-95b2-35d7f5ccbfa9"
    }
    policy_definition_reference { #Automatic provisioning of the Log Analytics monitoring agent should be enabled on your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/475aae12-b88a-4572-8b36-9b712b2b3a17"
    }
    policy_definition_reference { #A security contact email address should be provided for your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4f4f78b8-e367-4b10-a341-d9a4ad5cf1c7"
    }
    policy_definition_reference { #Vulnerability assessment should be enabled on virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/501541f7-f7e7-4cd6-868c-4190fdad3ac9"
    }
    policy_definition_reference { #Show audit results from Windows VMs configurations in 'Security Options - Network Security'
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5c028d2a-1889-45f6-b821-31f42711ced8"
    }
    policy_definition_reference { #External accounts with write permissions should be removed from your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5c607a2e-c700-4744-8254-d77e7c9eb5e4"
    }
    policy_definition_reference { #Deprecated accounts should be removed from your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6b1cbf55-e8b6-442f-ba4c-7246b6381474"
    }
    policy_definition_reference { #Function App should only be accessible over HTTPS
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6d555dd1-86f2-4f1c-8ed7-5abae7c6cbab"
    }
    policy_definition_reference { #Show audit results from Windows VMs configurations in 'Security Options - Microsoft Network Server'
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fe4ef56-7576-4dc4-8e9c-26bad4b087ce"
    }
    policy_definition_reference { #Show audit results from Windows VMs configurations in 'Administrative Templates - Network'
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/7229bd6a-693d-478a-87f0-1dc1af06f3b8"
    }
    policy_definition_reference { #Vulnerabilities should be remediated by a Vulnerability Assessment solution
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/760a85ff-6162-42b3-8d70-698e268f648c"
    }
    policy_definition_reference { #MFA should be enabled accounts with write permissions on your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9297c21d-2ed6-4474-b48f-163f75654ce3"
    }
    policy_definition_reference { #Show audit results from Windows VMs on which the Log Analytics agent is not connected as expected
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a030a57e-4639-4e8f-ade9-a92f33afe7ee"
    }
    policy_definition_reference { #Audit usage of custom RBAC rules
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a451c1ef-c6ca-483d-87ed-f49761e3ffb5"
    }
    policy_definition_reference { #Web Application should only be accessible over HTTPS
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a4af4a39-4135-47fb-b175-47fbdf85311d"
    }
    policy_definition_reference { #Auditing on SQL server should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9"
    }
    policy_definition_reference { #The Log Analytics agent should be installed on virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a70ca396-0a34-413a-88e1-b956c1e683be"
    }
    policy_definition_reference { #Azure DDoS Protection Standard should be enabled
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a7aca53f-2ed4-4466-a25e-0b45ade68efd"
    }
    policy_definition_reference { #MFA should be enabled on accounts with owner permissions on your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/aa633080-8b72-40c4-a2d7-d00c03e80bed"
    }
    policy_definition_reference { #Advanced data security should be enabled on your SQL servers
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/abfb4388-5bf4-4ad7-ba82-2cd2f41ceae9"
    }
    policy_definition_reference { #Advanced data security should be enabled on SQL Managed Instance
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/abfb7388-5bf4-4ad7-ba99-2cd2f41cebb9"
    }
    policy_definition_reference { #Monitor missing Endpoint Protection in Azure Security Center
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/af6cd1bd-1635-48cb-bde7-5b15693900b9"
    }
    policy_definition_reference { #API App should only be accessible over HTTPS
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b7ddfbdc-1260-477d-91fd-98bd9be789a6"
    }
    policy_definition_reference { #Deprecated accounts with owner permissions should be removed from your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ebb62a0c-3560-49e1-89ed-27e074e9f8ad"
    }
    policy_definition_reference { #Vulnerability assessment should be enabled on your SQL servers
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ef2a8f2a-b3d9-49cd-a8a8-9a3aaaf647d9"
    }
    policy_definition_reference { #The Log Analytics agent should be installed on Virtual Machine Scale Sets
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/efbde977-ba53-4479-b8e9-10b957924fbf"
    }
    policy_definition_reference { #The Log Analytics agent should be installed on virtual machines
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a70ca396-0a34-413a-88e1-b956c1e683be"
    }
    policy_definition_reference { #MFA should be enabled on accounts with read permissions on your subscription
        policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e3576e28-8b17-4677-84c3-db2990658d64"
    }      
}