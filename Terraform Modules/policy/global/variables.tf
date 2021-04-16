variable "org_name" {
    type = string
    description = "(requried) name to be used for labeling"
}

###############################################################

variable "create_baseline_policies" {
    type = bool
    default = true
    description = "(optional) Create baseline policies"
}
variable "create_logging_policies" {
    type = bool
    default = true
    description = "(optional) Create logging baseline policies"
}
variable "create_security_policies" {
    type = bool
    default = true
    description = "(optional) Create security baseline policies"
}
variable "create_hipaa_policies" {
    type = bool
    default = true
    description = "(optional) Create HIPAA policies"
}
variable "management_group_name" {
    type = string
    description = "(required) name of the management group to apply to"
}