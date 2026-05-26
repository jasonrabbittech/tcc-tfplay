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
  description = "Demo security group managed by Terraform"

  ingress_rules = [
    {
      action      = "ACCEPT"
      cidr_block  = "0.0.0.0/0"
      protocol    = "TCP"
      port        = "22"
      description = "Allow SSH"
    },
    {
      action      = "ACCEPT"
      cidr_block  = "0.0.0.0/0"
      protocol    = "TCP"
      port        = "80"
      description = "Allow HTTP"
    },
    {
      action      = "ACCEPT"
      cidr_block  = "10.0.0.0/16"
      protocol    = "ALL"
      port        = "ALL"
      description = "Allow intra-VPC"
    }
  ]

  tags = var.tags
}

module "cvm" {
  source = "../../modules/cvm"

  instance_name      = "${var.name_prefix}-cvm"
  hostname           = "${var.name_prefix}-cvm"
  availability_zone  = var.availability_zone
  instance_type      = "S5.MEDIUM2"
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.security_group_id]
  allocate_public_ip = true
  password           = var.cvm_password

  tags = var.tags
}

module "cos" {
  source = "../../modules/cos"

  bucket_name       = var.cos_bucket_name
  acl               = "private"
  versioning_enable = true

  tags = var.tags
}
