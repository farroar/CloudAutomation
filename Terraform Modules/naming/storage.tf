## resource groups
locals {
  # Alphanumeric, period, hyphen, underscore.
    stor = {
      #passthrough   = (var.type == "stor" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
      standard  = (var.type == "stor" && var.convention == "standard") ? substr("${local.filteredsubscription.alphanum}${local.filteredname.alphanum}${local.threedigitrandom_number}${lookup(var.az_postfix, var.type)}", 0, local.max) : null 
      #random        = (var.type == "stor" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
    }
}
output "stor" {
  depends_on = [local.stor]
  value = local.stor[var.convention]
}