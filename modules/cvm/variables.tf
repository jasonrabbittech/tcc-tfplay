variable "instance_name" {
  description = "实例名称"
  type        = string
}

variable "hostname" {
  description = "主机名"
  type        = string
  default     = "cvm-host"
}

variable "availability_zone" {
  description = "可用区"
  type        = string
}

variable "instance_type" {
  description = "实例规格，例如 S5.MEDIUM2"
  type        = string
  default     = "S5.MEDIUM2"
}

variable "image_id" {
  description = "镜像 ID，留空则使用 image_name_regex 自动匹配最新镜像"
  type        = string
  default     = ""
}

variable "image_name_regex" {
  description = "镜像名称匹配规则（image_id 为空时使用）"
  type        = string
  default     = "^TencentOS Server 3.1"
}

variable "system_disk_type" {
  description = "系统盘类型"
  type        = string
  default     = "CLOUD_PREMIUM"
}

variable "system_disk_size" {
  description = "系统盘大小 (GB)"
  type        = number
  default     = 50
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "子网 ID"
  type        = string
}

variable "security_group_ids" {
  description = "安全组 ID 列表（有序）"
  type        = list(string)
}

variable "allocate_public_ip" {
  description = "是否分配公网 IP"
  type        = bool
  default     = true
}

variable "internet_max_bandwidth_out" {
  description = "公网出带宽上限 (Mbps)"
  type        = number
  default     = 5
}

variable "password" {
  description = "登录密码（生产环境建议改用密钥对）"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "资源标签"
  type        = map(string)
  default     = {}
}
