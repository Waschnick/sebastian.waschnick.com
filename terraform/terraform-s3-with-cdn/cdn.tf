locals {
  cloudfront_origin_id = "origin-bucket-${aws_s3_bucket.website_root.id}"
}

data "aws_route53_zone" "main" {
  name = var.route53_domain_zone_name
}

module "public_certificate_cdn" {
  source  = "./terraform-module-cloudfront-certificate"
  domain  = local.domain_name
  zone_id = data.aws_route53_zone.main.zone_id
}

resource "aws_route53_record" "website_cdn_root_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn_root.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn_root.hosted_zone_id
    evaluate_target_health = false
  }
}

#module "lambda_cdn_basic_auth" {
#  count =
#  source = "./cdn-basic-auth"
#  stage  = var.stage
#}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${local.domain_name}.s3.amazonaws.com"
}


resource "aws_s3_bucket_policy" "website_root_policy" {
  bucket = aws_s3_bucket.website_root.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid     = "1"
    actions = ["s3:GetObject", "s3:ListBucket"]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket-name}",
      "arn:aws:s3:::${local.bucket-name}/*",
    ]
  }
}

# CloudFront
# Creates the CloudFront distribution to serve the static website
resource "aws_cloudfront_distribution" "website_cdn_root" {
  comment     = "CDN for S3 bucket ${local.domain_name}"
  enabled     = true
  price_class = "PriceClass_All"
  aliases     = [local.domain_name]

  origin {
    origin_id = local.cloudfront_origin_id
    //    domain_name = "${var.domain_name}.s3.amazonaws.com"
    domain_name = aws_s3_bucket.website_root.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.cloudfront_origin_id

    // Default 12h, min 1h, max 1d
    default_ttl = 43200
    min_ttl     = 3600
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
    # Redirects any HTTP request to HTTPS
    compress = true

    forwarded_values {
      query_string = false
      headers      = []

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.root-to-index-cf-function.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.public_certificate_cdn.cert_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_page_path    = "/error/40x.html"
    response_code         = 404
  }

  lifecycle {
    ignore_changes = [
      viewer_certificate,
    ]
  }
}