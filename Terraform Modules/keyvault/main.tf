module "kv_name" {
  source            = "../naming"
  
  name              = "keyvault"
  org_name          = "${var.org_name}"
  subscription_name = "${var.subscription_name}"
  location          = "${var.location}"
  convention        = "gpcxstandard"
  type              = "kv"
}

module "rg_name" {
  source            = "../naming"
  
  name              = "keyvault"
  org_name          = "${var.org_name}"
  subscription_name = "${var.subscription_name}"
  location          = "${var.location}"
  convention        = "gpcxstandard"
  type              = "rg"
}

resource "azurerm_resource_group" "rg" {
  name     = "${module.rg_name.rg}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

resource "azurerm_key_vault" "vault" {
  name                        = "${module.kv_name.kv}"
  location                    = "${azurerm_resource_group.rg.location}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"

  sku_name = "standard"

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.object_id}"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = "${var.tags}"
}