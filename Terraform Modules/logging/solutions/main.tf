resource "azurerm_log_analytics_solution" "az_activity_solution" {
  solution_name         = "AzureActivity"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  workspace_resource_id = "${var.workspace_id}"
  workspace_name        = "${var.workspace_name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureActivity"
  }
}

resource "azurerm_log_analytics_solution" "az_dns_solution" {
  solution_name         = "DnsAnalytics"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  workspace_resource_id = "${var.workspace_id}"
  workspace_name        = "${var.workspace_name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/DnsAnalytics"
  }
}

resource "azurerm_log_analytics_solution" "az_network_solution" {
  solution_name         = "NetworkMonitoring"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  workspace_resource_id = "${var.workspace_id}"
  workspace_name        = "${var.workspace_name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/NetworkMonitoring"
  }
}

resource "azurerm_log_analytics_solution" "az_service_solution" {
  solution_name         = "ServiceMap"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  workspace_resource_id = "${var.workspace_id}"
  workspace_name        = "${var.workspace_name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ServiceMap"
  }
}

resource "azurerm_log_analytics_solution" "az_keyvault_solution" {
  solution_name         = "KeyVaultAnalytics"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  workspace_resource_id = "${var.workspace_id}"
  workspace_name        = "${var.workspace_name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/KeyVaultAnalytics"
  }
}