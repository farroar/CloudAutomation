## resource groups
locals {
  # Alphanumeric, period, hyphen, underscore.
    vm = {
      #passthrough   = (var.type == "afw" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
      gpcxstandard  = (var.type == "vm" && var.convention == "gpcxstandard") ? substr("${local.filteredorgname.alphanumhup}-${local.filtered.alphanumhup}", 0, local.max) : null 
      #random        = (var.type == "afw" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
    }
}
output "vm" {
  depends_on = [local.vm]
  value = local.vm[var.convention]
}