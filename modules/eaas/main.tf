variable "domain" {}
variable "env" {
  default = null
}
variable "vm_config" {}
variable "dns_config" {}

module "installer" {
  source = "../eaas-installer"
  domain = var.domain
  env    = var.env
}

locals {
  ports = ["22", "80", "443", "3478", "3478/udp"]
}

module "server" {
  source = "../vm"
  config = merge(var.vm_config, {
    ports = concat(try(var.vm_config.ports, []), local.ports)
  })
  name      = var.domain
  user_data = module.installer.user_data
}

module "dns" {
  source = "../dns"
  config = var.dns_config
  domain = var.domain
  ip     = module.server.ip
}

output "domain" {
  value = var.domain
}
