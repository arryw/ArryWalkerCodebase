locals {
  ec2 = {
    dev = {
      example-app = {
        region   = "eu-west-1"
        vpc      = "arryw-dev-dublin"
        count    = 2
        az       = ["eu-west-1a", "eu-west-1b"]
        key_pair = "arryw"
        policies = ["rds"]
      }
      example-router = {
        region    = "eu-west-1"
        vpc       = "arryw-dev-dublin"
        count     = 1
        az        = ["eu-west-1a"]
        key_pair  = "arryw"
        eni_route = true
      }
    }
  }
}