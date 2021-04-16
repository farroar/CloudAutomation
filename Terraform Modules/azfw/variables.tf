variable "resource_group_name" {}
variable "location" {}
variable "address_prefix" {}
variable "virtual_network_name" {}
variable "org_name" {}
variable "subscription_name" {}

variable "tags" {
    description = "resoruce tags"
    default = {}
}