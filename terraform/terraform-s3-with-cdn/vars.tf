variable "bucket_name" {
  type = string
}

variable "route53_domain_zone_name" {
  type = string
}

variable "subdomain-name" {
  type = string
}

variable "basic_auth_enabled" {
  type    = string
  default = false
}

