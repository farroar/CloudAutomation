// Resource Group
/*
module "fgt_rg_name" {
  source = "../../naming"
  name = "fgt"
  org_name = var.org_name
  subscription_name = var.subscription_name
  location = var.location
  convention = "gpcxstandard"
  type = "rg"

}

resource "azurerm_resource_group" "fgt_resource_group" {
  name     = module.fgt_rg_name.rg
  location = var.location

  tags = var.tags

}
*/