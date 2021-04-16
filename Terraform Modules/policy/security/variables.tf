variable "policy_id" {
    type = string
    description = "(required) ID of the policy to be assigned"
}
variable "scope" {
    type = string
    description = "(required) specify if this is to be applied to a 'management_group' or a 'subscription'"
}
variable "location" {
    type = string
    description = "(required) A location is required for the managed identity to be created"
}
variable "org_name" {
    type = string
    description = "(required) organizational name"
}

######################################################

variable "assign_security_policies" {
    type = bool
    default = false
    description = "(optional) enable the assignment of policies"
}
variable "management_group_name" {
    type = string
    description = "(optional) if applying to a management group, specify the name of the group"
    default = ""
}
variable "subscription_id" {
    type = string
    description = "(optional) if applying to a subscription, specify the ID of the subscription"
    default = ""
}