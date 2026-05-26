output "vpc_id" {
  description = "VPC ID"
  value       = tencentcloud_vpc.this.id
}

output "subnet_id" {
  description = "子网 ID"
  value       = tencentcloud_subnet.this.id
}
