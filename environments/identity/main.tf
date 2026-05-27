###############################################################################
# Identity Center governance for Tencent Cloud
#
# This stack manages SSO (Identity Center) role bindings only.
# It is intentionally separated from environments/default (compute / network)
# so that IAM changes have an independent state, approval gate, and blast radius.
###############################################################################

# 1. Create role configuration (the "permission set" template)
resource "tencentcloud_identity_center_role_configuration" "role_cdb_admin" {
  zone_id                 = var.zone_id
  role_configuration_name = var.role_configuration_name
  description             = var.role_configuration_description
}

# 2. Attach a pre-defined policy (e.g. 219185 = QcloudCDBFullAccess)
resource "tencentcloud_identity_center_role_configuration_permission_policy_attachment" "assign_predefined_policy" {
  zone_id               = var.zone_id
  role_configuration_id = tencentcloud_identity_center_role_configuration.role_cdb_admin.role_configuration_id
  role_policy_name      = var.predefined_policy_name
  role_policy_id        = var.predefined_policy_id
}

# 3. Attach a customized policy (in this case full VPC permissions)
resource "tencentcloud_identity_center_role_configuration_permission_custom_policy_attachment" "assign_custom_policy" {
  zone_id               = var.zone_id
  role_configuration_id = tencentcloud_identity_center_role_configuration.role_cdb_admin.role_configuration_id
  role_policy_name      = var.custom_policy_name
  role_policy_document  = var.custom_policy_document
}

# 4. Assign the role configuration to a SSO user, scoped to a member account
resource "tencentcloud_identity_center_role_assignment" "identity_center_role_assignment" {
  zone_id               = var.zone_id
  principal_id          = var.principal_id
  principal_type        = "User"
  target_uin            = var.target_uin
  target_type           = "MemberUin"
  role_configuration_id = tencentcloud_identity_center_role_configuration.role_cdb_admin.role_configuration_id
}
