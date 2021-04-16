variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "address_prefix" {}
variable "location" {}

variable "tags" {
    description = "resoruce tags"
    default = {}
}