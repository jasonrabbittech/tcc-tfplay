output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "子网 ID"
  value       = module.vpc.subnet_id
}

output "security_group_id" {
  description = "安全组 ID"
  value       = module.security_group.security_group_id
}

output "cvm_instance_id" {
  description = "CVM 实例 ID"
  value       = module.cvm.instance_id
}

output "cvm_public_ip" {
  description = "CVM 公网 IP"
  value       = module.cvm.public_ip
}

output "cvm_private_ip" {
  description = "CVM 内网 IP"
  value       = module.cvm.private_ip
}

output "cos_bucket_url" {
  description = "COS Bucket 访问域名"
  value       = module.cos.bucket_url
}
