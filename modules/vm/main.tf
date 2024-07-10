module "vm" {
  count     = true || var.config.provider == "vm" ? 1 : 0
  source    = "./providers"
  config    = var.config
  name      = var.name
  user_data = var.user_data
}

output "ip" {
  value = try([for k, v in module.vm.0 : v if split("-", k)[0] == "ip" && v != null][0], null)
}
