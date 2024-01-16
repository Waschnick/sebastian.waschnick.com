module "terraform-s3-with-cdn" {
  source = "./terraform-s3-with-cdn"

  bucket_name              = "sebastian.waschnick.com"
  route53_domain_zone_name = "waschnick.com"
  subdomain-name           = "sebastian"
}

#resource "aws_route53_record" "website_cdn_record" {
#  zone_id = data.aws_route53_zone.main.zone_id
#  name    = "sebastian.${local.root_domain_name}"
#  type    = "A"
#
#  alias {
#    name                   = module.terraform-s3-with-cdn.domain_name
#    zone_id                = module.terraform-s3-with-cdn.hosted_zone_id
#    evaluate_target_health = false
#  }
#}

resource "aws_route53_record" "website_www_redirect_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${local.root_domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_de_cdn_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.website_de_cdn_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "website_apex_redirect_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.root_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_de_cdn_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.website_de_cdn_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}


