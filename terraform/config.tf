terraform {
  backend "s3" {
    bucket  = "finanzassistent-dev-terraform"
    key     = "statefiles/services/homeadvantageapi"
    encrypt = false
    region  = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
}
