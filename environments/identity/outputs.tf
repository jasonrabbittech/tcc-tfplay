output "role_configuration_id" {
  description = "Role configuration ID created in Identity Center"
  value       = tencentcloud_identity_center_role_configuration.role_cdb_admin.role_configuration_id
}

output "role_configuration_name" {
  description = "Role configuration name"
  value       = tencentcloud_identity_center_role_configuration.role_cdb_admin.role_configuration_name
}

output "assigned_principal" {
  description = "SSO user assigned to this role"
  value       = var.principal_id
}

output "target_member_uin" {
  description = "Member account UIN where this role applies"
  value       = var.target_uin
}
