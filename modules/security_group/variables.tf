variable "name" {
  description = "安全组名称"
  type        = string
}

variable "description" {
  description = "安全组描述"
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = "入站规则列表"
  type = list(object({
    action      = string
    cidr_block  = string
    protocol    = string
    port        = string
    description = string
  }))
  default = []
}

variable "egress_rules" {
  description = "出站规则列表"
  type = list(object({
    action      = string
    cidr_block  = string
    protocol    = string
    port        = string
    description = string
  }))
  default = [
    {
      action      = "ACCEPT"
      cidr_block  = "0.0.0.0/0"
      protocol    = "ALL"
      port        = "ALL"
      description = "Allow all outbound traffic"
    }
  ]
}

variable "tags" {
  description = "资源标签"
  type        = map(string)
  default     = {}
}
