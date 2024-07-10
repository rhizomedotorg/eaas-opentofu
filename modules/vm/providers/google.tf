module "google" {
  count     = var.config.provider == "google" ? 1 : 0
  source    = "../../vm-google"
  config    = var.config
  name      = var.name
  user_data = var.user_data
}

output "ip-google" {
  value = try([for k, v in module.google.0 : v if split("-", k)[0] == "ip" && v != null][0], null)
}
