variable "environment" {
  type        = string
  default     = "dev"
  description = "The environment to deploy the resources"
}

locals {
  vpc = {
    dev = {
      # vpc_key = [region, vpc_cidr, [subnet_cidr1, subnet_cidr2, subnet_cidr3]]
      arryw-dev-dublin = ["eu-west-1", "10.0.0.0/23", ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]]
    }
  }

  # Assign an index to route tables
  rt_dub_index = {
    for k in sort(keys(aws_route_table.public_dub)) : k => {
      id     = aws_route_table.public_dub[k].id
      index  = index(sort(keys(aws_route_table.public_dub)), k)
      az     = try(regex(".*(eu-west-1[abcd])", k)[0], "default-value-or-empty-string")
      vpc_id = aws_route_table.public_dub[k].vpc_id
    }
  }

  # Flatten the structure for route creation
  flattened_rt_routes_dub = local.rt_dub_index != null ? flatten([
    for rt_key, rt in local.rt_dub_index : [
      for route_key, route in local.public_routes[var.environment] : merge(
        rt,
        {
          vpc_id       = rt.vpc_id
          vpc_key      = route[1]
          rt_key       = rt_key
          route_key    = route_key
          route_region = route[0]
          route_target = route[2]
          route_cidr   = route[3]
          az           = rt.az
        }
      )
      if route[0] == "eu-west-1"
    ]
  ]) : []

  # Convert to map with readable, immutable key
  rt_routes_map_dub = {
    for idx, route in local.flattened_rt_routes_dub : "${route.rt_key}-${route.route_key}" => route
  }
}

resource "aws_vpc" "vpc_dub" {
  for_each = {
    for k, v in local.vpc[var.environment] : k => v
    if v.0 == "eu-west-1"
  }
  provider             = aws.dublin
  cidr_block           = each.value[1]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.global_tags, {
    Name = each.key
  })
}
resource "aws_internet_gateway" "igw_dub" {
  for_each = {
    for k, v in local.vpc[var.environment] : k => v
    if v.0 == "eu-west-1"
  }
  provider = aws.dublin
  vpc_id   = aws_vpc.vpc_dub[each.key].id
}
resource "aws_subnet" "public_subnet_dub" {
  for_each = {
    for idx, subnet in local.subnet_map : idx => subnet
    if subnet.region == "eu-west-1"
  }
  provider          = aws.dublin
  vpc_id            = aws_vpc.vpc_dub[each.value.vpc_key].id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
}
resource "aws_route_table" "public_dub" {
  for_each = {
    for idx, rt in local.subnet_map : idx => rt
    if rt.region == "eu-west-1"
  }
  provider = aws.dublin
  vpc_id   = aws_vpc.vpc_dub[each.value.vpc_key].id
}
resource "aws_route_table_association" "public_dub" {
  for_each = {
    for idx, rt in local.subnet_map : idx => rt
    if rt.region == "eu-west-1"
  }
  provider       = aws.dublin
  subnet_id      = aws_subnet.public_subnet_dub[each.key].id
  route_table_id = aws_route_table.public_dub[each.key].id
}

locals {
  public_routes = {
    dev = {
      some_public_eni_route = ["eu-west-1", "arryw-dev-dublin", "eni", "10.2.0.0/23"]
      some_public_route     = ["eu-west-1", "arryw-dev-dublin", "igw", "8.8.8.8/32"]
    }
  }

  # Flatten ec2 instances and subnets
  flattened_ec2_subnet = length(local.flattened_ec2_map) > 0 ? flatten([
    for ec2_key, ec2 in local.flattened_ec2_map : [
      for rt_key, rt in local.subnet_map : {
        vpc_key = rt.vpc_key
        ec2_key = ec2_key
        ec2_az  = ec2.az
        rt_key  = rt_key
        rt_az   = rt.az
      }
      if ec2.az == rt.az
    ]
  ]) : []

  # Flatted route tables, routes & ec2 instances so we can sent a route to the ENI
  flattened_rt_routes_ec2_dub = length(local.rt_dub_index) > 0 ? flatten([
    for rt_key, rt in local.flattened_rt_routes_dub : [
      for ec2_key, ec2 in local.ec2_map : {
        rt_key        = rt.rt_key
        rt_index      = rt.index
        route_key     = rt.route_key
        route_name    = "${rt.route_key}-${rt.az}-${ec2_key}"
        route_target  = rt.route_target
        route_cidr    = rt.route_cidr
        az            = rt.az
        ec2_index     = ec2.index
        ec2_key       = ec2_key
        ec2_az        = ec2.az
        ec2_eni_route = try(ec2.eni_route, null)
      }
      if ec2.index == rt.index && ec2.az == rt.az
    ]
  ]) : []
}

resource "aws_route" "public_igw_route_dub" {
  for_each = {
    for idx, route in local.rt_routes_map_dub : idx => route
    if route.route_target == "igw" && route.route_region == "eu-west-1"
  }
  provider               = aws.dublin
  route_table_id         = aws_route_table.public_dub[each.value.rt_key].id
  destination_cidr_block = each.value.route_cidr
  gateway_id             = aws_internet_gateway.igw_dub[each.value.vpc_key].id
}

resource "aws_route" "public_eni_route_dub" {
  for_each = {
    for idx, route in local.flattened_rt_routes_ec2_dub : route.route_name => route
    if route.route_target == "eni" && route.ec2_eni_route == true
  }
  provider               = aws.dublin
  route_table_id         = aws_route_table.public_dub[each.value.rt_key].id
  destination_cidr_block = each.value.route_cidr
  network_interface_id   = aws_instance.ec2_dub[each.value.ec2_key].primary_network_interface_id
}