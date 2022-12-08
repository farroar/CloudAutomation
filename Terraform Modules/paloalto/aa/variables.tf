variable "location" {
    type = string
    description = "(optional) describe your variable"
}

variable "mgmt_subnet_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "outside_subnet_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "inside_subnet_id" {
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

variable "vm_params" {
    type = map(string)
}