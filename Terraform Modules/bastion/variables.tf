variable "resource_group_name" {}
variable "location" {}
variable "virtual_network_name" {}
variable "address_prefix" {}
variable "org_name" {}
variable "subscription_name" {}

variable "tags" {
    description = "resoruce tags"
    default = {}
}