# ./tests/ec2_values_mapped.tftest.hcl

variables {
  environment = "stage"
}

# Run block to validate the Staging environment
run "validate_ec2_map_stage" {
  command = plan

  # Check EC2 object has a region, VPC, and count
  assert {
    condition = alltrue([for _, ec2 in local.ec2_map : lookup(ec2, "region", null) != null])
    error_message = "All EC2 instances must have a defined region in the Staging environment."
  }
  assert {
    condition = alltrue([for _, ec2 in local.ec2_map : lookup(ec2, "vpc", null) != null])
    error_message = "All EC2 instances must have a defined VPC in the Staging environment."
  }
  assert {
    condition = alltrue([for _, ec2 in local.ec2_map : lookup(ec2, "count", null) != null])
    error_message = "All EC2 instances must have a defined count in the Staging environment."
  }
}

run "validate_ec2_vpc_stage" {
  command = plan

  # Test vpc value of an EC2 is being defined in code
  assert {
    condition = alltrue([
      for _, ec2 in local.ec2_map :
      contains(
        keys(local.vpc[var.environment]),
        lookup(ec2, "vpc", "")
      )
    ])
    error_message = "VPC not found for the specified region in the Staging environment."
  }

  # Test that each EC2 instance's region matches the expected region from the VPC list
  assert {
    condition = alltrue([
      for _, ec2 in local.ec2_map :
      # Check if the EC2 instance's region matches the first item in the corresponding VPC's value list
      lookup(ec2, "region", "") == local.vpc[var.environment][keys(local.vpc[var.environment])[0]][0]
    ])
    error_message = "Region mismatch between EC2 instances and VPC in the Staging environment."
  }
}