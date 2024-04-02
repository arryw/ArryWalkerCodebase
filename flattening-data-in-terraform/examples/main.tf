terraform {
  required_version = ">= 1.7.5"
}

provider "aws" {
  region                   = "eu-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "arryw-dev-dublin"
}

provider "aws" {
  alias   = "dublin"
  region  = "eu-west-1"
  profile = "arryw-dev-dublin"
}
provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "arryw-dev-dublin"
}
provider "aws" {
  alias   = "mumbai"
  region  = "ap-south-1"
  profile = "arryw-dev-dublin"
}