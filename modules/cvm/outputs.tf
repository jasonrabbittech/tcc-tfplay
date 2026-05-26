output "instance_id" {
  description = "CVM 实例 ID"
  value       = tencentcloud_instance.this.id
}

output "private_ip" {
  description = "内网 IP"
  value       = tencentcloud_instance.this.private_ip
}

output "public_ip" {
  description = "公网 IP"
  value       = tencentcloud_instance.this.public_ip
}
