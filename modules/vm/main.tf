variable "config" {
  type = object({
    provider = string
  })
}
variable "name" {}
variable "user_data" {}

module "openstack" {
  count     = var.config.provider == "openstack" ? 1 : 0
  source    = "../vm-openstack"
  name      = var.name
  config    = var.config
  user_data = var.user_data
}

module "google" {
  count     = var.config.provider == "google" ? 1 : 0
  source    = "../vm-google"
  name      = var.name
  config    = var.config
  user_data = var.user_data
}

output "ip" {
  value = try(module.openstack.0.ip, module.google.0.ip)
}
