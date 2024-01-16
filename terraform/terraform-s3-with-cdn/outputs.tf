output "domain_name" {
  value = local.domain_name
}

output "website_s3_bucket" {
  value = local.bucket-name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.website_cdn_root.hosted_zone_id
}
