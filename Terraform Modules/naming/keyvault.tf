## keyvault
locals {
    # Alphanumeric, hyphen. Must start with a letter.
    kv = {
        #passthrough = (var.type == "kv" && var.convention == "passthrough") ? substr(local.filtered_extend.alphanumh_startletter, 0, local.max) : null
        standard  = (var.type == "kv" && var.convention == "standard") ? substr("${local.filteredorgname.alphanumhup}-${local.filteredsubscription.alphanumhup}-${local.filtered.alphanumhup}${local.filteredpostfix.alphanumhup}${lookup(var.az_postfix, var.type)}", 0, local.max) : null 
        #random      = (var.type == "kv" && var.convention == "random") ? substr(local.fullyrandom_startletter, 0, local.max) : null
    }
 }

output "kv" {
    depends_on = [local.kv]
    value = local.kv[var.convention]
}