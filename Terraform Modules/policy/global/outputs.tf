output "baseline_id" {
  value = azurerm_policy_set_definition.baseline[0].id
}
output "logging_baseline_id" {
    value = azurerm_policy_set_definition.logging_baseline[0].id
}
output "security_baseline_id" {
    value = azurerm_policy_set_definition.security_baseline[0].id
}
output "hipaa_id" {
    value = azurerm_policy_set_definition.hipaa_policy[0].id
}