variable "config" {
  type = object({
    type  = optional(string, "n2-standard-2")
    image = optional(string, "ubuntu-os-cloud/ubuntu-2204-lts")
    size  = optional(number, 50)
  })
  default = {}
}
variable "name" {}
variable "user_data" {
  default = ""
}

resource "google_compute_instance" "server" {
  name         = replace(var.name, "/[^-a-z0-9]/", "-")
  machine_type = var.config.type

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
