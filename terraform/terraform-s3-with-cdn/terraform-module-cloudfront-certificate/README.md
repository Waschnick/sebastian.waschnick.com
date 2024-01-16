# terraform-module-cloudfront-certificate


## Usage

```
module "public_certificate_cdn" {
  source = "s3::https://s3-eu-central-1.amazonaws.com/ush-dev-terraform-modules/cloudfront-certificate.zip"

  domain  = var.domain_name
  zone_id = data.aws_route53_zone.main.zone_id
}
```
