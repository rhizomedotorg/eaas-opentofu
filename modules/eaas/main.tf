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

module "server" {
  source    = "../vm"
  config    = var.vm_config
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
