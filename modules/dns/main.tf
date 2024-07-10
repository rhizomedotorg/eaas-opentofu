module "dns" {
  count  = true || var.config.provider == "dns" ? 1 : 0
  source = "./providers"
  config = var.config
  domain = var.domain
  ip     = var.ip
}
