## virtual network
locals {
  # alphanum 1-80 with hypen, underscore and period.
    vnet = {
      #passthrough   = (var.type == "vnet" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
      standard  = (var.type == "vnet" && var.convention == "standard") ? substr("${local.filteredorgname.alphanumhup}-${var.location}-${local.filteredsubscription.alphanumhup}${local.filteredpostfix.alphanumhup}${lookup(var.az_postfix, var.type)}", 0, local.max) : null 
      #random        = (var.type == "vnet" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
    }
 }
output "vnet" {
  depends_on = [local.vnet]
  value      = local.vnet[var.convention]
}