# 自动查当前凭证所属账号的 APPID，用于拼接 COS 桶名（COS bucket 名必须以 -<APPID> 结尾）
data "tencentcloud_user_info" "current" {}

locals {
  app_id          = data.tencentcloud_user_info.current.app_id
  cos_bucket_name = coalesce(var.cos_bucket_name, "${var.name_prefix}-app-${local.app_id}")
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name          = "${var.name_prefix}-vpc"
  vpc_cidr          = "10.0.0.0/16"
  subnet_name       = "${var.name_prefix}-subnet"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = var.availability_zone

  tags = var.tags
}

module "security_group" {
  source = "../../modules/security_group"

  name        = "${var.name_prefix}-sg"
  description = "Strict SG: ingress closed, egress allows only ICMP + DNS"

  # 入向全关：不允许任何入站连接
  ingress_rules = []

  # 出向最小化：只允许 ICMP（ping）和 UDP/53（DNS 解析）
  egress_rules = [
    {
      action      = "ACCEPT"
      cidr_block  = "0.0.0.0/0"
      protocol    = "ICMP"
      port        = "ALL"
      description = "Allow outbound ping (ICMP)"
    },
    {
      action      = "ACCEPT"
      cidr_block  = "0.0.0.0/0"
      protocol    = "UDP"
      port        = "53"
      description = "Allow outbound DNS"
    }
  ]

  tags = var.tags
}

module "cvm" {
  source = "../../modules/cvm"

  instance_name      = "${var.name_prefix}-cvm"
  hostname           = "${var.name_prefix}-cvm"
  availability_zone  = var.availability_zone
  instance_type      = "SA2.MEDIUM2"
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.security_group_id]
  allocate_public_ip = true
  password           = var.cvm_password

  tags = var.tags
}

module "cos" {
  source = "../../modules/cos"

  bucket_name          = local.cos_bucket_name
  acl                  = "private"
  versioning_enable    = true
  encryption_algorithm = "AES256" # SSE-COS

  tags = var.tags
}
