//  For HA, choose instance size that support 4 nics at least
//  Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
variable "size" {
  type    = string
  default = "Standard_F4s"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "org_name" {
  type = string
}

variable "subscription_name" {
  type = string
}

variable "subscription_id" {
  type = string
}
// To use custom image
// by default is false
variable "custom" {
  default = false
}

//  Custom image blob uri
variable "customuri" {
  type    = string
  default = "https://<location of the custom image blob uri>"
}

variable "custom_image_name" {
  type    = string
  default = "<custom image name>"
}

variable "custom_image_resource_group_name" {
  type    = string
  default = "<custom image resource group>"
}

variable "publisher" {
  type    = string
  default = "fortinet"
}

variable "fgt_offer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

variable "fgt_sku" {
  type    = string
  default = "fortinet_fg-vm"
}

variable "fgt_version" {
  type    = string
  default = "6.4.3"
}

variable "fgt_rg_name" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "fgtadmin"
}

variable "admin_password" {
  type    = string
  default = "Fortinet123#"
}

// HTTPS Port
variable "admin_port" {
  type    = string
  default = "8443"
}

variable "vnet_name" {
  type = string
}

variable "vnet_rg_name" {
  type = string
}

variable "vnet_cidr" {
  default = "10.1.0.0/16"
}

variable "outside_subnet" {
  default = "10.1.0.0/24"
}

variable "inside_subnet" {
  default = "10.1.1.0/24"
}

variable "bootstrap" {
  // Path to the primary config with fabric connector
  type    = string
  default = "/config.conf"
}

variable "fgt_name" {
  type    = string
  default = "fgt" 
}

variable "tags" {
  default = {}
}

