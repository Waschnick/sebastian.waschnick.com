# Redirect from waschnick.com

locals {
  root_domain_name     = "waschnick.com"
  redirect_bucket_name = "${local.root_domain_name}-redirect"
}

data "aws_route53_zone" "main" {
  name = local.root_domain_name
}

module "public_certificate_waschnick_com" {
  source  = "./cloudfront_cert"
  domain  = local.root_domain_name
  zone_id = data.aws_route53_zone.main.zone_id
}

resource "aws_s3_bucket" "website_redirect_de" {
  bucket        = local.redirect_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "website_root_s3_bucket_ownership" {
  bucket = aws_s3_bucket.website_redirect_de.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_root_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_redirect_de.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "aws_s3_website" {
  bucket = aws_s3_bucket.website_redirect_de.id

  index_document {
    suffix = "index.html"
  }

  #  redirect_all_requests_to {
  #    host_name = "sebastian.waschnick.com"
  #    protocol  = "https"
  #  }

  routing_rule {
    redirect {
      host_name          = "sebastian.waschnick.com"
      http_redirect_code = "301"
      protocol           = "https"
    }
  }
}

resource "aws_cloudfront_distribution" "website_de_cdn_redirect" {
  comment     = "Redirect from apex to sebasitan.waschnick.com"
  enabled     = true
  price_class = "PriceClass_All"
  aliases     = [local.root_domain_name, "www.${local.root_domain_name}"]

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_redirect_de.id}"
    domain_name = aws_s3_bucket.website_redirect_de.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_redirect_de.id}"
    min_ttl          = "0"
    default_ttl      = "0"
    max_ttl          = "0"

    viewer_protocol_policy = "redirect-to-https"
    # Redirects any HTTP request to HTTPS
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.public_certificate_waschnick_com.cert_arn
    ssl_support_method  = "sni-only"
  }

  lifecycle {
    ignore_changes = [
      tags,
      viewer_certificate,
    ]
  }
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${local.root_domain_name}.s3.amazonaws.com"
}


resource "aws_s3_bucket_policy" "website_root_policy" {
  bucket = aws_s3_bucket.website_redirect_de.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid     = "1"
    actions = ["s3:GetObject", "s3:ListBucket"]
    principals {
      type        = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }

    resources = [
      "arn:aws:s3:::${local.redirect_bucket_name}",
      "arn:aws:s3:::${local.redirect_bucket_name}/*",
    ]
  }
}
