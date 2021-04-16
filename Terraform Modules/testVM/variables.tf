variable "location" {
    description = "Specify region, must be in same region as vnet"
}

variable "subnet_name" {
    description = "Specify subnet name"
}

variable "vnet_name" {
    description = "Specify vnet"
}

variable "vnet_resource_group" {
    description = "Specify the resoruce group used for the vnet/subnets"
}

variable "is_linux" {
    description = "(Optional) Specify windows or linux"
    default = false
}



