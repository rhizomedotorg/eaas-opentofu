variable "config" {
  type = object({
    type  = optional(string, "n2-standard-2")
    image = optional(string, "ubuntu-os-cloud/ubuntu-2204-lts")
    size  = optional(number, 50)
    ports = optional(list(string), [])

  })
  default = {}
}
variable "name" {}
variable "user_data" {
  default = ""
}

locals {
  firewall_description = "ports ${join(", ", var.config.ports)}"
  firewall_name        = replace(local.firewall_description, "/[^-a-z0-9]+/", "-")
}

resource "google_compute_firewall" "default" {
  name    = local.firewall_name
  network = "default"

  allow {
    protocol = "icmp"
  }

  dynamic "allow" {
    for_each = var.config.ports
    content {
      protocol = try(split("/", allow.value)[1], "tcp")
      ports    = [split("/", allow.value)[0]]
    }
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.firewall_name]
}

resource "google_compute_instance" "server" {
  name         = replace(var.name, "/[^-a-z0-9]/", "-")
  machine_type = var.config.type
  tags         = [local.firewall_name]

  boot_disk {
    initialize_params {
      image = var.config.image
      size  = var.config.size
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    user-data = "${var.user_data}"
  }
}

output "ip" {
  value = resource.google_compute_instance.server.network_interface.0.access_config.0.nat_ip
}
