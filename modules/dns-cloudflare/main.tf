variable "config" {
  default = null
}
variable "domain" {}
variable "ip" {}
variable "type" {
  default = "A"
}

data "cloudflare_zone" "zone" {
  filter = {
    name = join(".", reverse(slice(reverse(split(".", var.domain)), 0, 2)))
  }
}

resource "cloudflare_dns_record" "www" {
  zone_id = data.cloudflare_zone.zone.zone_id
  name    = var.domain
  type    = var.type
  content = var.ip
  ttl     = 1
}
