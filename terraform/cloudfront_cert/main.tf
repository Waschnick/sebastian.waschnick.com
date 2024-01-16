module "wildcard_certificate_us_east_1" {
  source               = "github.com/terraform-aws-modules/terraform-aws-acm.git?ref=v2.5.0"
  domain_name          = var.domain
  zone_id              = var.zone_id
  create_certificate   = var.create_certificate
  validate_certificate = var.validate_certificate

  subject_alternative_names = [
    "*.${var.domain}",
  ]
}
