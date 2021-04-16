locals {
  prefix_name = "${var.org_name}-${var.subscription_name}"
}


resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix_name}-diagnostics-rg"
  location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefix_name}-la"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "ChangeTrackingSolution" {
  solution_name         = "ChangeTracking"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }
}
resource "azurerm_log_analytics_solution" "KeyVaultSolution" {
  solution_name         = "KeyVaultAnalytics"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/KeyVaultAnalytics"
  }
}
resource "azurerm_log_analytics_solution" "UpdatesSolution" {
  solution_name         = "Updates"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}