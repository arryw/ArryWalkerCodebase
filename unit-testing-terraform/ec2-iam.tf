resource "aws_iam_role" "ec2_role" {
  for_each = {
    for k, v in lookup(local.ec2, var.environment) : k => v
  }
  name               = "${each.key}-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = merge(local.global_tags, {})
}

resource "aws_iam_instance_profile" "ec2_profile" {
  for_each = {
    for k, v in lookup(local.ec2, var.environment) : k => v
  }
  provider = aws.dublin
  name     = "${each.key}-ec2-instance-profile"
  role     = aws_iam_role.ec2_role[each.key].name
  tags     = merge(local.global_tags, {})
}

resource "aws_iam_role_policy" "rds_policy" {
  for_each = {
    for k, v in lookup(local.ec2, var.environment) : k => v
    if contains(try(v.policies, []), "rds")
  }

  name   = "${each.key}-ec2-rds-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  role   = aws_iam_role.ec2_role[each.key].id
}