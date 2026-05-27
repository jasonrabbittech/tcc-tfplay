variable "bucket_name" {
  description = "Bucket 名称，必须带 APPID 后缀，例如 demo-1250000000"
  type        = string
}

variable "acl" {
  description = "访问权限：private / public-read / public-read-write"
  type        = string
  default     = "private"
}

variable "versioning_enable" {
  description = "是否开启版本控制"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "服务端加密算法。SSE-COS 使用 AES256；不加密填空字符串"
  type        = string
  default     = "AES256"
}

variable "tags" {
  description = "资源标签"
  type        = map(string)
  default     = {}
}
