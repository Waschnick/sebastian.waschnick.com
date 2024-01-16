locals {
  bucket-name = var.bucket_name
  domain_name = "${var.subdomain-name}.${var.route53_domain_zone_name}"
}

resource "aws_s3_bucket" "website_root" {
  bucket        = local.bucket-name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_root_configuration" {
  bucket = aws_s3_bucket.website_root.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_root_s3_bucket_ownership" {
  bucket = aws_s3_bucket.website_root.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_root_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_root.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}