## resource groups
locals {
  # Alphanumeric, period, hyphen, underscore.
    afw = {
      #passthrough   = (var.type == "afw" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
      standard  = (var.type == "afw" && var.convention == "standard") ? substr("${local.filteredorgname.alphanumhup}-${var.location}-${local.filteredsubscription.alphanumhup}${local.filteredpostfix.alphanumhup}${lookup(var.az_postfix, var.type)}", 0, local.max) : null 
      #random        = (var.type == "afw" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
    }
}
output "afw" {
  depends_on = [local.afw]
  value = local.afw[var.convention]
}