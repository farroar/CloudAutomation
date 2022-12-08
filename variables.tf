variable "vm_params" {
    type = map(string)
    default = {
      publisher = "paloaltonetworks"
      sku = "bundle1"
      offer = "vmseries-flex"
      vm_size = "Standard_D3_v2"
      admin_user = "admin"
      admin_pass = "Password1234!"
    }
}

variable "environment_vars" {
  type = map(string)
}

variable "vnet" {
}

variable "subnets" {
}


variable "deploy_rserver" {
  type = bool
  default = false
}

variable "deploy_gateway" {
  type = bool
  default = false
}

variable "deploy_bastion" {
  type = bool
  default = false
}