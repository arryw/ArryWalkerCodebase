locals {
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

output "ec2_map" {
  value = local.ec2_map
}