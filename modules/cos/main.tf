resource "tencentcloud_cos_bucket" "this" {
  bucket            = var.bucket_name
  acl               = var.acl
  versioning_enable = var.versioning_enable

  tags = var.tags
}
