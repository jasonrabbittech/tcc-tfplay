resource "tencentcloud_vpc" "this" {
  name         = var.vpc_name
  cidr_block   = var.vpc_cidr
  is_multicast = false

  tags = var.tags
}

resource "tencentcloud_subnet" "this" {
  name              = var.subnet_name
  vpc_id            = tencentcloud_vpc.this.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = var.tags
}
