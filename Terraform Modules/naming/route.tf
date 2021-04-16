## virtual network
locals {
  # alphanum 1-80 with hypen, underscore and period.
    route = {
      #passthrough   = (var.type == "route" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
      gpcxstandard  = (var.type == "route" && var.convention == "gpcxstandard") ? substr("${local.filteredorgname.alphanumhup}-${var.location}-${local.filteredsubscription.alphanumhup}-${local.filtered.alphanumhup}${local.filteredpostfix.alphanumhup}${lookup(var.az_postfix, var.type)}", 0, local.max) : null 
      #random        = (var.type == "route" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
    }
 }
output "route" {
  depends_on = [local.route]
  value      = local.route[var.convention]
}