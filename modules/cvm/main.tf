data "tencentcloud_images" "default" {
  image_type       = ["PUBLIC_IMAGE"]
  image_name_regex = var.image_name_regex
  instance_type    = var.instance_type
}

resource "tencentcloud_instance" "this" {
  instance_name              = var.instance_name
  availability_zone          = var.availability_zone
  image_id                   = length(var.image_id) > 0 ? var.image_id : data.tencentcloud_images.default.images.0.image_id
  instance_type              = var.instance_type
  system_disk_type           = var.system_disk_type
  system_disk_size           = var.system_disk_size
  hostname                   = var.hostname
  project_id                 = 0
  vpc_id                     = var.vpc_id
  subnet_id                  = var.subnet_id
  orderly_security_groups    = var.security_group_ids
  allocate_public_ip         = var.allocate_public_ip
  internet_max_bandwidth_out = var.allocate_public_ip ? var.internet_max_bandwidth_out : 0
  password                   = var.password

  tags = var.tags
}
