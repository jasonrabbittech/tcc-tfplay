output "bucket_name" {
  description = "Bucket 名称"
  value       = tencentcloud_cos_bucket.this.bucket
}

output "bucket_url" {
  description = "Bucket 访问域名"
  value       = tencentcloud_cos_bucket.this.cos_bucket_url
}
