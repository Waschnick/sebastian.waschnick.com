terraform {
  backend "s3" {
    bucket  = "terraform-states-sebastian-waschnick"
    key     = "sebastian-waschnick-com"
    encrypt = true
    region  = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
}
