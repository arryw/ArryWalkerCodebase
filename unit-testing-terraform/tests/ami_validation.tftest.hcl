# ./tests/ami_validation.tftest.hcl

# Run block to validate the Staging environment
run "validate_ami_staging" {
  command = plan

  variables {
    environment = "stage"
  }

  # Assertion for Staging: EC2 instances without 'app' in the key must have an AMI
  assert {
    condition = length([
      for key, ec2_data in local.ec2[var.environment] :
      key if !strcontains(key, "app") && lookup(ec2_data, "ami", null) != null
    ]) == length([
      for key, ec2_data in local.ec2[var.environment] :
      key if !strcontains(key, "app")
    ])
    error_message = "AMIs must be defined for EC2 instances without 'app' in their key in the Staging environment."
  }
}

# Run block to validate the Prod environment
run "validate_ami_prod" {
  command = plan

  variables {
    environment = "prod"
  }

  # Assertion for Prod: EC2 instances without 'app' in the key must have an AMI
  assert {
    condition = length([
      for key, ec2_data in local.ec2[var.environment] :
      key if !strcontains(key, "app") && lookup(ec2_data, "ami", null) != null
    ]) == length([
      for key, ec2_data in local.ec2[var.environment] :
      key if !strcontains(key, "app")
    ])
    error_message = "AMIs must be defined for EC2 instances without 'app' in their key in the Prod environment."
  }
}

