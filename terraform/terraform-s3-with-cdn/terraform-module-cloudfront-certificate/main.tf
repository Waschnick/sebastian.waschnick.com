module "wildcard_certificate_us_east_1" {
  source      = "github.com/terraform-aws-modules/terraform-aws-acm.git?ref=v4.3.2"
  domain_name = var.domain
  zone_id     = var.zone_id

  subject_alternative_names = [
    "*.${var.domain}",
  ]
}
