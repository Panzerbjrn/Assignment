# Azure AD Module Outputs

# Group IDs
output "developer_group_id" {
  description = "The Object ID of the Developers Azure AD group"
  value       = azuread_group.developers.id
}

output "dba_group_id" {
  description = "The Object ID of the DBA Azure AD group"
  value       = azuread_group.dba.id
}

output "operations_group_id" {
  description = "The Object ID of the Operations Azure AD group"
  value       = azuread_group.operations.id
}

output "auditor_group_id" {
  description = "The Object ID of the Auditors Azure AD group"
  value       = azuread_group.auditors.id
}

# Group Names
output "developer_group_name" {
  description = "The display name of the Developers Azure AD group"
  value       = azuread_group.developers.display_name
}

output "dba_group_name" {
  description = "The display name of the DBA Azure AD group"
  value       = azuread_group.dba.display_name
}

output "operations_group_name" {
  description = "The display name of the Operations Azure AD group"
  value       = azuread_group.operations.display_name
}

output "auditor_group_name" {
  description = "The display name of the Auditors Azure AD group"
  value       = azuread_group.auditors.display_name
}

# Test User Principal Names (only when test users are created)
output "test_user_principal_names" {
  description = "Map of test user principal names by role"
  value = var.create_test_users ? {
    developer = azuread_user.test_developer[0].user_principal_name
    dba       = azuread_user.test_dba[0].user_principal_name
    ops       = azuread_user.test_ops[0].user_principal_name
    auditor   = azuread_user.test_auditor[0].user_principal_name
  } : {}
}

