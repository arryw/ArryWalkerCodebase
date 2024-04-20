locals {
  vpc = {
    dev = {
      # vpc_key = [region, vpc_cidr, [subnet_cidr1, subnet_cidr2, subnet_cidr3]]
      arryw-dev-dublin = ["eu-west-1", "10.0.0.0/23", ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]]
    }
    qa = {
      arryw-qa-dublin = ["eu-west-1", "10.0.2.0/23", ["10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26"]]
    }
    prod = {
      arryw-prod-dublin = ["eu-west-1", "10.0.4.0/23", ["10.0.4.0/26", "10.0.4.64/26", "10.0.4.128/26"]]
    }
  }

  public_routes = {
    dev = {
      some_public_eni_route = ["eu-west-1", "arryw-dev-dublin", "eni", "192.168.0.0/23"]
      some_public_route     = ["eu-west-1", "arryw-dev-dublin", "igw", "8.8.8.8/32"]
    }
    qa = {
      some_public_eni_route = ["eu-west-1", "arryw-qa-dublin", "eni", "192.168.2.0/23"]
      some_public_route     = ["eu-west-1", "arryw-qa-dublin", "igw", "8.8.8.8/32"]
    }
    prod = {
      some_public_eni_route = ["eu-west-1", "arryw-prod-dublin", "eni", "192.168.4.0/23"]
      some_public_route     = ["eu-west-1", "arryw-prod-dublin", "igw", "8.8.8.8/32"]
    }
  }
}