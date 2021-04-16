locals {
  hipaa_initiative_name                 = "${var.org_name}-hipaaInitiative"
  hipaa_initiative_display_name         = "${var.org_name}-HIPAA policy initiative"
}

####################################################################
                    #Initiative
####################################################################

resource "azurerm_policy_set_definition" "hipaa_policy" {
  count = var.create_hipaa_policies ? 1 : 0
  name                  = local.hipaa_initiative_name
  policy_type           = "Custom"
  display_name          = local.hipaa_initiative_display_name
  management_group_name = var.management_group_name


policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2835b622-407b-4114-9198-6f7064cbe0dc"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/86b3d65f-7626-441e-b690-81a8b71cff60"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a7ff3161-0087-490a-9ad9-ad6217f4f43a"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0961003e-5a0a-4549-abde-af6a37f2724d"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/17k78e20-9358-41c9-923c-fb736d382a12"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/21e2995e-683e-497a-9e81-2f42ad07050a"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/498b810c-59cd-4222-9338-352ba146ccf3"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/225e937e-d32e-4713-ab74-13ce95b3519a"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0a9991e6-21be-49f9-8916-a06d934bcf29"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a9a33475-481d-4b81-9116-0bf02ffe67e8"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/42a07bbf-ffcf-459a-b4b1-30ecd118a505"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1b7aa243-30e4-4c9e-bca8-d0d3022b634a"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/760a85ff-6162-42b3-8d70-698e268f648c"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fe4ef56-7576-4dc4-8e9c-26bad4b087ce"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/86880e5c-df35-43c5-95ad-7e120635775e"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0d134df8-db83-46fb-ad72-fe0c9428c8dd"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e9c8d085-d9cc-4b17-9cdc-059f1f01f19e"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cb510bfd-1cba-4d9f-a230-cb0976f4bb71"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b7ddfbdc-1260-477d-91fd-98bd9be789a6"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f48b2913-1dc5-4834-8c72-ccc1dfd819bb"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/7ed40801-8a0f-4ceb-85c0-9fd25c1d61a8"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b872a447-cc6f-43b9-bccf-45703cd81607"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e5b81f87-9185-4224-bf00-9f505e9f89f3"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/22730e10-96f6-4aac-ad84-9383d35b5917"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3c735d8a-a4ba-4a3a-b7cf-db7754cf57f4"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c3f317a7-a95c-4547-b7e7-11017ebdf2fe"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/013e242c-8828-4970-87b3-ab247555486d"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/08e6af2d-db70-460a-bfe9-d5bd474ba9d6"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/09024ccc-0c5f-475e-9457-b7c0d9ed487b"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0b60c0b2-2dc2-4e1c-b5c9-abbed971de53"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0e60b895-3786-45da-8377-9c6b4b6ac5f9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/10ee2ea2-fb4d-45b8-a7e9-a2e770044cd9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1a4e592a-6a6e-44a5-9814-e36264ca96e7"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2c89a2e5-7285-40fe-afe0-ae8654b92fb2"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/35f9c03a-cc27-418e-9c0c-539ff999d010"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/41388f1c-2db0-4c25-95b2-35d7f5ccbfa9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/475aae12-b88a-4572-8b36-9b712b2b3a17"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4f11b553-d42e-4e3a-89be-32ca364cad4c"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/501541f7-f7e7-4cd6-868c-4190fdad3ac9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5bb220d9-2698-4ee4-8404-b9c30c9df609"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/60d21c4f-21a3-4d94-85f4-b924e6aeeda4"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6d555dd1-86f2-4f1c-8ed7-5abae7c6cbab"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a030a57e-4639-4e8f-ade9-a92f33afe7ee"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a451c1ef-c6ca-483d-87ed-f49761e3ffb5"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a4af4a39-4135-47fb-b175-47fbdf85311d"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/feedbf84-6b99-488c-acc2-71c829aa5ffc"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f9d614c5-c173-4d56-95a7-b4437057d193"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f6de0be7-9a8a-4b8a-b349-43cf02d22f7c"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ef2a8f2a-b3d9-49cd-a8a8-9a3aaaf647d9"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ebb62a0c-3560-49e1-89ed-27e074e9f8ad"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e8cbc669-f12d-49eb-93e7-9273119e9933"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e802a67a-daf5-4436-9ea6-f6d821dd0c5d"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d38fc420-0735-4ef3-ac11-c806f651a570"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ae5d2f14-d830-42b6-9899-df6cfe9c71a3"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/22bee202-a82f-4305-9a2a-6d7f44d4dedb"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/235359c5-7c52-4b82-9055-01c75cf9f60e"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/26a828e1-e88f-464e-bbb3-c134a282b9de"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2d21331d-a4c2-4def-a9ad-ee4e1e023beb"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/48af4db5-9b8b-401c-8e74-076be876a430"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/82339799-d096-41ae-8538-b108becf0970"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b0f33259-77d7-4c9e-aac6-3aabcfae693c"
  }
policy_definition_reference { # 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0ec47710-77ff-4a3d-9181-6aa50af424d0"
  }
}