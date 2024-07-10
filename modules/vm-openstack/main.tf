variable "config" {
  type = object({
    region          = optional(string, null)
    type            = optional(string, "m1.medium")
    image           = optional(string, "Ubuntu 22.04")
    network         = optional(string, "public")
    size            = optional(number, 50)
    security_groups = optional(list(string), [])
    ports           = optional(list(string), [])
    key_pair        = optional(string, null)
  })
  default = {}
}
variable "name" {}
variable "user_data" {
  default = ""
}

data "openstack_images_image_v2" "image" {
  region      = var.config.region
  name        = var.config.image
  most_recent = true
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  count  = length(var.config.ports) > 0 ? 1 : 0
  name   = "ports ${join(", ", var.config.ports)}"
  region = var.config.region
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  for_each          = toset(var.config.ports)
  region            = var.config.region
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = try(split("/", each.value)[1], "tcp")
  port_range_min    = tonumber(split("/", each.value)[0])
  port_range_max    = tonumber(split("/", each.value)[0])
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup[0].id
}

resource "openstack_compute_instance_v2" "server" {
  name        = var.name
  region      = var.config.region
  flavor_name = var.config.type
  image_id    = var.config.size > 0 ? null : data.openstack_images_image_v2.image.id
  security_groups = length(var.config.security_groups) == 0 && length(var.config.ports) == 0 ? ["default"] : concat(
  try([openstack_networking_secgroup_v2.secgroup[0].name], []), var.config.security_groups)
  user_data = var.user_data
  key_pair  = var.config.key_pair

  network {
    name = var.config.network
  }

  dynamic "block_device" {
    for_each = var.config.size > 0 ? [true] : []
    content {
      uuid                  = data.openstack_images_image_v2.image.id
      source_type           = "image"
      volume_size           = var.config.size
      destination_type      = "volume"
      delete_on_termination = true
    }
  }
}

output "ip" {
  value = openstack_compute_instance_v2.server.access_ip_v4
}
