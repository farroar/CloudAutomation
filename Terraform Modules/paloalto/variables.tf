variable "vm_params" {
    type = map(string)
}

variable "location" {
    type = string
    description = "(optional) describe your variable"
}

variable "vnet_resource_group_name" {
    type = string
    description = "(optional) describe your variable"
}
variable "mgmt_subnet_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "outside_subnet_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "inside_subnet_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "vnet_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "org_name" {
    type = string
}

variable "environment" {
    type = string
}