variable "security_rules" {
  type        = list(map(string))
  description = "NSG rule sets in a list of maps that contain strings. Must have: name, priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix"
  default = [
      {
        name                       = "DenyAllOut"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
  ]
}

variable "resource_group_name" {
  type = string
  description = "Name of the resource group where the NSG will be placed"
}

variable "location" {
  type = string
  description = "Location where NSG will be placed"
}

variable "nsg_name" {
  type = string
  description = "Name of the NSG"
}


