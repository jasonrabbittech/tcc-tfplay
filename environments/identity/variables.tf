variable "region" {
  description = "腾讯云 region（Identity Center 是全局服务，但 provider 仍需 region）"
  type        = string
  default     = "ap-hongkong"
}

variable "zone_id" {
  description = "Identity Center 实例 zone_id（在主账号 Identity Center 控制台查看）"
  type        = string
  # 例：z-71c8dwf2w3q3 — 用 GitHub Variable IDENTITY_ZONE_ID 注入
}

variable "principal_id" {
  description = "被授权的 SSO 用户 ID（u-xxxx）"
  type        = string
  # 例：u-2jt99e06qde1 — 用 GitHub Variable IDENTITY_PRINCIPAL_ID 注入
}

variable "target_uin" {
  description = "目标成员账号 UIN（被赋权的账号）"
  type        = string
  # 例：200048944863 — 用 GitHub Variable IDENTITY_TARGET_UIN 注入
}

variable "role_configuration_name" {
  description = "Role configuration 名称"
  type        = string
  default     = "cdb_admin"
}

variable "role_configuration_description" {
  description = "Role 描述"
  type        = string
  default     = "cdb_admin"
}

variable "predefined_policy_name" {
  description = "预定义策略名称（带 po 后缀，例如 219185po）"
  type        = string
  default     = "219185po"
}

variable "predefined_policy_id" {
  description = "预定义策略 ID（数字，例如 219185 表示 QcloudCDBFullAccess）"
  type        = number
  default     = 219185
}

variable "custom_policy_name" {
  description = "自定义策略名称"
  type        = string
  default     = "vpc-admin"
}

variable "custom_policy_document" {
  description = "自定义策略 JSON 文档"
  type        = string
  default     = <<-EOT
  {
      "version": "2.0",
      "statement": [
          {
              "effect": "allow",
              "action": [
                  "vpc:*"
              ],
              "resource": [
                  "*"
              ]
          }
      ]
  }
  EOT
}
