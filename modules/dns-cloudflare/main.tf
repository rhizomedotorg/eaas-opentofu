variable "config" {
  default = null
}
variable "domain" {}
variable "ip" {}
variable "type" {
  default = "A"
}

data "cloudflare_zone" "zone" {
  name = join(".", reverse(slice(reverse(split(".", var.domain)), 0, 2)))
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.zone.id
  name    = var.domain
  type    = var.type
  value   = var.ip
}
