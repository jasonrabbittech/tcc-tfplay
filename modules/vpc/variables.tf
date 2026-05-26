variable "vpc_name" {
  description = "VPC 名称"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 网段"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "子网名称"
  type        = string
}

variable "subnet_cidr" {
  description = "子网 CIDR 网段"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "可用区，例如 ap-hongkong-2"
  type        = string
}

variable "tags" {
  description = "资源标签"
  type        = map(string)
  default     = {}
}
