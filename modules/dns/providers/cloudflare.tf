module "cloudflare" {
  count  = var.config.provider == "cloudflare" ? 1 : 0
  source = "../../dns-cloudflare"
  config = var.config
  domain = var.domain
  ip     = var.ip
}
