variable "config" {
  type = object({
    provider = string
  })
}
variable "domain" {}
variable "ip" {}

module "cloudflare" {
  count  = var.config.provider == "cloudflare" ? 1 : 0
  source = "../dns-cloudflare"
  domain = var.domain
  ip     = var.ip
}
