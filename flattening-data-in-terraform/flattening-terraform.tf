locals {
  ec2 = {
    dev = {
      arryw-app = {
        region        = "eu-west-1"
        count         = 2
        az            = ["eu-west-1a", "eu-west-1b"]
        ami           = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
        another_key   = "another-value"
      }
    }
  }

  flattened_ec2 = flatten([
    for k, v in local.ec2[var.environment] : [
      for i in range(v.count) : merge(
        v,
        {
          indexed_key  = "${k}_${i}"
          indexed_name = "${k}-${i}"
          az           = v["az"][i % length(v["az"])]
        }
      )
    ]
  ])

  flattened_ec2_map = {
    for ec2 in local.flattened_ec2 : ec2.indexed_key => ec2
  }
}

resource "aws_instance" "ec2_dub" {
  for_each = {
    for k, v in local.flattened_ec2_map : k => v
    if v.region == "eu-west-1"
  }
  provider      = aws.dublin
  ami           = each.value.ami
  instance_type = each.value.instance_type
}