variable "domain" {}
variable "zone_id" {}
variable "create_certificate" {
  default = true
}
variable "validate_certificate" {
  default = true
}

provider "aws" {
  region = "us-east-1"
}
