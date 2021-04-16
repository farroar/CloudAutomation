variable "azure_firewall_name" {
    description = "Azure firewall name (required)"
}

variable "azure_firewall_rg" {
    description = "Resource group the firewall lives in (required)"
}

variable "source_addresses" {
    description = "(optional) Source IP prefix, type of list"
    default     = ["*"]
}

