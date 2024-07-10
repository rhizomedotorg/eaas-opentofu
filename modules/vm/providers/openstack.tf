module "openstack" {
  count     = var.config.provider == "openstack" ? 1 : 0
  source    = "../../vm-openstack"
  config    = var.config
  name      = var.name
  user_data = var.user_data
}

output "ip-openstack" {
  value = try([for k, v in module.openstack.0 : v if split("-", k)[0] == "ip" && v != null][0], null)
}
