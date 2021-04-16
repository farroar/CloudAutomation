variable "location" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "route_table_name" {
  type = "string"
}

variable "tags" {
  description = "resoruce tags"
  default = {}
}
