variable "domain" {}
variable "env" {
  default = {
    https                    = "1",
    acmesh                   = "1",
    setup_keycloak           = "1",
    import_test_environments = "1",
    show_summary             = "1",
  }
  nullable = false
}

module "userscript" {
  source = "../userscript"
  script = "${path.module}/userdata"
  env    = merge(var.env, { domain = var.domain })
}

output "ports" {
  value = ["22", "80", "443", "3478", "3478/udp"]
}
output "domain" {
  value = var.domain
}
output "user_data" {
  value = module.userscript.user_data
}
