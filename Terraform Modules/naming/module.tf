/*resource "random_string" "fullrandom" {
  # count = (var.convention == "random" || var.convention == "cafrandom" )  == true ? 1 : 0
  length  = local.max
  special = false
  lower   = true
  upper   = false
}
*/
resource "random_string" "singlechar" {
  length  = 1
  special = false
  number = false
  upper = false
}

resource "random_string" "singlealphanum" {
  length  = 1
  special = false
  number = true
  upper = false
}

resource "random_integer" "threedigitrandom" {
  min = 100
  max = 999
}

# random
locals {
  #random                  = random_string.fullrandom.result
  singlerandom_letter     = random_string.singlechar.result
  singlerandom_alphanum   = random_string.singlealphanum.result
  threedigitrandom_number = random_integer.threedigitrandom.result
} 

# regexes and charset filters
locals {
  filter_alphanum= "/[^0-9A-Za-z]/"
  filter_alphanumh   = "/[^0-9A-Za-z,-]/"
  filter_alphanumu   = "/[^0-9A-Za-z,_]/"
  filter_alphanumhu  = "/[^0-9A-Za-z,_,-]/"
  filter_alphanumhup = "/[^0-9A-Za-z,_,.,-]/"
  filter_startletter = "/\\A[^a-z]/"
}

# determine max capacity
locals {
  max         = lookup(var.azlimits, var.type)
  # maxrandom   = local.max - length(local.filtered.alphanum) - length(lookup(var.caf_prefix, var.type)) - length(var.postfix)
}

## filtered inputs 
locals {
  filtered = {
    alphanum    = replace(var.name, local.filter_alphanum, "")
    alphanumhup = replace(var.name, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.name, local.filter_alphanumhu, "")
    alphanumh   = replace(var.name, local.filter_alphanumh, "")
  }
  filteredorgname = {
    alphanum    = replace(var.org_name, local.filter_alphanum, "")
    alphanumhup = replace(var.org_name, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.org_name, local.filter_alphanumhu, "")
    alphanumh   = replace(var.org_name, local.filter_alphanumh, "")
  }
  filteredsubscription = {
    alphanum    = replace(var.subscription_name, local.filter_alphanum, "")
    alphanumhup = replace(var.subscription_name, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.subscription_name, local.filter_alphanumhu, "")
    alphanumh   = replace(var.subscription_name, local.filter_alphanumh, "")
  }
  filteredpostfix = {
    alphanum    = replace(var.postfix, local.filter_alphanum, "")
    alphanumhup = replace(var.postfix, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.postfix, local.filter_alphanumhu, "")
    alphanumh   = replace(var.postfix, local.filter_alphanumh, "")
  }
  filteredlocation = {
    alphanum    = replace(var.postfix, local.filter_alphanum, "")
    alphanumhup = replace(var.postfix, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.postfix, local.filter_alphanumhu, "")
    alphanumh   = replace(var.postfix, local.filter_alphanumh, "")
  }
  filteredidentifier = {
    alphanum    = replace(var.identifier, local.filter_alphanum, "")
    alphanumhup = replace(var.identifier, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.identifier, local.filter_alphanumhu, "")
    alphanumh   = replace(var.identifier, local.filter_alphanumh, "")
  }
  filteredname= {
    alphanum    = replace(var.name, local.filter_alphanum, "")
    alphanumhup = replace(var.name, local.filter_alphanumhup, "")
    alphanumhu  = replace(var.name, local.filter_alphanumhu, "")
    alphanumh   = replace(var.name, local.filter_alphanumh, "")
  }
}

locals {
  filtered_extend = {
    alphanum_startletter = replace(local.filtered.alphanum, local.filter_startletter, local.singlerandom_letter)
    alphanumh_startletter = replace(local.filtered.alphanumh, local.filter_startletter, local.singlerandom_letter)
    alphanumhup_startletter = replace(local.filtered.alphanumhup, local.filter_startletter, local.singlerandom_letter)
  }
}

#generic outputs
/*
locals {
  fullyrandom             = (var.convention == "random" || var.convention == "cafrandom")  == true ? substr(local.random, 0, local.max) : null
  fullyrandom_startletter = (var.convention == "random" || var.convention == "cafrandom")  == true ? substr("${local.singlerandom_letter}${local.random}", 0, local.max) : null
}
*/