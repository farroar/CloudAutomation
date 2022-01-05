variable "name" {
  description = "(Required) input name"
}

variable "org_name" {
  description = "(Required) Organizational identifier/name"
}

variable "subscription_name" {
  description = "(Required) subscription identifier/name"
}

variable "location" {
  description = "(Required) location of resoruce"
}

variable "identifier" {
  description = "(Optional) additional identifier for name, added before postifx and type designations"
  default = ""
}

variable "type" {
  description = "(Required) type of resource created as described in the README"
}

variable "convention" {
  description = "(Required) naming convention methode to be used"
}

variable "postfix" {
  description = "(Optional) additional postfix to add to name"
  default = ""
}

variable "azlimits" {
  description = "(Optional) limit for resources"
  default = {
    "asr"           = 50
    "aaa"           = 50
    "acr"           = 49
    "afw"           = 50
    #afw limit is 80 - not working need to investigate - safeguarding it at 50 during investigation
    "rg"            = 90
    "kv"            = 24 
    "st"            = 24
    "vnet"          = 64
    "nsg"           = 80
    "snet"          = 80
    "nic"           = 80
    "vml"           = 64 
    "vmw"           = 15
    "functionapp"   = 60
    "lb"            = 80
    "lbrule"        = 80
    "evh"           = 50
    "la"            = 63
    "pip"           = 80
    "gen"           = 24
    "route"         = 80
    "stor"          = 24
    "vm"            = 15
   }
}



variable "az_postfix" {
  description = "Standard recommended postfix"
  default = {
    "asr"           = "-asr"
    "aaa"           = "-aaa"
    "afw"           = "-afw"
    "acr"           = "-acr"
    "kv"            = "-kv"
    "rg"            = "-rg"
    "st"            = "-st"
    "evh"           = "-evh"
    "vnet"          = "-vnet"
    "snet"          = "-snet"
    "nsg"           = "-nsg"
    "vm"            = "-vm"
    "vml"           = "-vm"
    "vmw"           = "-vm"
    "lb"            = "-lb"
    "la"            = "-la"
    "pip"           = "-pip"
    "gen"           = "-gen"
    "route"         = "-route"
    "stor"          = "stor"
  }
}

# variable "naming_constraints" {
  
# }
