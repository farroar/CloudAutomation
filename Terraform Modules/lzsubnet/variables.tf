variable "route_table_id" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_name" {}
variable "virtual_network_name" {}
variable "subnet_prefix" {}
variable "subscription_name" {}

variable "tags" {
    description = "resoruce tags"
    default = {}
}
