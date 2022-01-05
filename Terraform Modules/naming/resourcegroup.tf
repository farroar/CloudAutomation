## resource groups
locals {
  # Alphanumeric, period, hyphen, underscore.
    rg = {
      #passthrough   = (var.type == "rg" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
      standard  = (var.type == "rg" && var.convention == "standard") ? substr("${local.filteredorgname.alphanumhup}-${var.location}-${local.filteredsubscription.alphanumhup}-${local.filtered.alphanumhup}${local.filteredpostfix.alphanumhup}${lookup(var.az_postfix, var.type)}", 0, local.max) : null 
      #random        = (var.type == "rg" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
    }
}
output "rg" {
  depends_on = [local.rg]
  value = local.rg[var.convention]
}