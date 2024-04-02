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
      #      example-router = {
      #        region    = "eu-west-1"
      #        vpc       = "arryw-dev-dublin"
      #        count     = 1
      #        az        = ["eu-west-1a"]
      #        key_pair  = "arryw"
      #        eni_route = true
      #      }
    }
  }

  flattened_ec2 = flatten([
    for k, v in local.ec2[var.environment] : [
      for i in range(v.count) : merge(
        v,
        {
          ec2_key      = k
          index        = i
          indexed_key  = "${k}_${i}"
          indexed_name = "${k}-${i}"
          az           = v["az"][i % length(v["az"])]
        }
      )
    ]
  ])

  ec2_map = {
    for ec2 in local.flattened_ec2 : ec2.indexed_key => ec2
  }
}
output "flattened_ec2" {
  value = local.flattened_ec2
}
output "ec2_map" {
  value = local.ec2_map
}

#resource "aws_instance" "ec2_dub" {
#  for_each = {
#    for k, v in local.ec2_map : k => v
#    if v.region == "eu-west-1"
#  }
#  provider      = aws.dublin
#  ami           = each.value.ami
#  instance_type = try(each.value.instance_type, "t4g.micro")
#}