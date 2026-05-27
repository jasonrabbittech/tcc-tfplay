variable "region" {
  description = "腾讯云区域"
  type        = string
  default     = "ap-hongkong"
}

variable "availability_zone" {
  description = "可用区"
  type        = string
  default     = "ap-hongkong-2"
}

variable "name_prefix" {
  description = "资源名称前缀"
  type        = string
  default     = "demo"
}

variable "cos_bucket_name" {
  description = "COS Bucket 名称，必须带 APPID 后缀，例如 demo-app-1250000000"
  type        = string
}

variable "cvm_password" {
  description = "CVM 登录密码（通过 TF_VAR_cvm_password 环境变量传入，不要写到 tfvars）"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "通用资源标签（腾讯云有保留 tag 前缀 cos:/qcs:/tke:，先留空，验证资源能起来再加）"
  type        = map(string)
  default     = {}
}
