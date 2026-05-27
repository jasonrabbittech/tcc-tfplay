resource "tencentcloud_cos_bucket" "this" {
  bucket            = var.bucket_name
  acl               = var.acl
  versioning_enable = var.versioning_enable

  # SSE-COS：使用腾讯云托管密钥的服务端加密（AES256）
  encryption_algorithm = var.encryption_algorithm

  tags = var.tags
}
