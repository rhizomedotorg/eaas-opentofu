variable "config" {
  type = object({
    type            = optional(string, "m1.medium")
    image           = optional(string, "Ubuntu 22.04")
    size            = optional(number, 50)
    security_groups = optional(list(string), ["http(s)"])
  })
  default = {}
}
variable "name" {}
variable "user_data" {
  default = ""
}

data "openstack_images_image_v2" "image" {
  name        = var.config.image
  most_recent = true
}

resource "openstack_compute_instance_v2" "server" {
  name            = var.name
  flavor_name     = var.config.type
  image_id        = var.config.size > 0 ? null : data.openstack_images_image_v2.image.id
  security_groups = var.config.security_groups
  user_data       = var.user_data
  key_pair        = "default"

  network {
    name = "public"
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
