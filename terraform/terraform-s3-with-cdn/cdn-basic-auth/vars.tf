variable "stage" {}

provider "aws" {
  region = "us-east-1"
}

locals {
  is_production        = var.stage == "production" ? true : false
  production_count     = var.stage == "production" ? 1 : 0
  non_production_count = var.stage == "production" ? 0 : 1
}