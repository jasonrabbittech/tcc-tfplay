resource "tencentcloud_security_group" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags
}

resource "tencentcloud_security_group_rule_set" "this" {
  security_group_id = tencentcloud_security_group.this.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      action      = ingress.value.action
      cidr_block  = ingress.value.cidr_block
      protocol    = ingress.value.protocol
      port        = ingress.value.port
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      action      = egress.value.action
      cidr_block  = egress.value.cidr_block
      protocol    = egress.value.protocol
      port        = egress.value.port
      description = egress.value.description
    }
  }
}
