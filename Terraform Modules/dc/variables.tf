variable "location" {
    type = string
    description = "(optional) describe your variable"
}

variable "vm_short_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "org_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "subscription_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "tags" {
    type = map(string)
    description = "(optional) describe your variable"
}

variable "data_disk_size" {
    type = string
    description = "(optional) describe your variable"
}

variable "vm_sku" {
    type = string
    description = "(optional) describe your variable"
}

variable "vm_size" {
    type = string
    description = "(optional) describe your variable"
}

variable "diag_account_uri" {
    type = string
    description = "(optional) describe your variable"
}

variable "private_ip_address" {
    type = string
    description = "(optional) describe your variable"
}

variable "subnet_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "timezone" {
    type = string
    description = "Eastern Standard Time"
}

variable "dc_admin_password" {
    type = string
    description = "(optional) describe your variable"
}

variable "dc_admin_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "backup_rg_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "recovery_vault_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "backup_policy_id" {
    type = string
    description = "(optional) describe your variable"
}