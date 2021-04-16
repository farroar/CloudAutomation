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

variable "fgt_ha_fabric_conn" {
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
  default = ["10.1.0.0/24"]
}

variable "inside_subnet" {
  default = "10.1.1.0/24"
}

variable "ha_subnet" {
  default = "10.1.2.0/24"
}

variable "mgmt_subnet" {
  default = "10.1.3.0/24"
}
/*
variable "activeport1" {
  default = "10.1.0.10"
}

variable "activeport1mask" {
  default = "255.255.255.0"
}

variable "activeport2" {
  default = "10.1.1.10"
}

variable "activeport2mask" {
  default = "255.255.255.0"
}

variable "activeport3" {
  default = "10.1.2.10"
}

variable "activeport3mask" {
  default = "255.255.255.0"
}

variable "activeport4" {
  default = "10.1.3.10"
}

variable "activeport4mask" {
  default = "255.255.255.0"
}

variable "secondaryport1" {
  default = "10.1.0.11"
}

variable "secondaryport1mask" {
  default = "255.255.255.0"
}

variable "secondaryport2" {
  default = "10.1.1.11"
}

variable "secondaryport2mask" {
  default = "255.255.255.0"
}

variable "secondaryport3" {
  default = "10.1.2.11"
}

variable "secondaryport3mask" {
  default = "255.255.255.0"
}

variable "secondaryport4" {
  default = "10.1.3.11"
}

variable "secondaryport4mask" {
  default = "255.255.255.0"
}

variable "port1gateway" {
  default = "10.1.0.1"
}

variable "port4gateway" {
  default = "10.1.3.1"
}
*/
variable "bootstrap-primary-sdn" {
  // Path to the primary config with fabric connector
  type    = string
  default = "/config-primary-sdn.conf"
}

variable "bootstrap-secondary-sdn" {
  // Path to the secondary config with fabric connector
  type    = string
  default = "/config-secondary-sdn.conf"
}

variable "bootstrap-primary-lb" {
  // Path to the primary lb config with load balancer
  type    = string
  default = "config-primary-lb.conf"
}

variable "bootstrap-secondary-lb" {
  // Path to the secondary lb config with load balancer
  type    = string
  default = "config-secondary-lb.conf"
}

variable "fgt_a_name" {
  type    = string
  default = "fgt-a" 
}

variable "tags" {
  default = {}
}

variable "fgt_client_secret" {
  type = string
}

variable "fgt_client_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

