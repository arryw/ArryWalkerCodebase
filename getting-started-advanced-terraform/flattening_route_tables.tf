variable "environment" {
  type = string
  default = "dev"
  description = "The environment to deploy the resources"
}

locals {
  vpc = {
    dev = {
      # vpc_key = [region, vpc_cidr, [subnet_cidr1, subnet_cidr2, subnet_cidr3]]
      arryw-dev-dublin = ["eu-west-1", "10.0.0.0/23", ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]]
    }
  }

  # Flatten the structure for subnet creation
  flattened_subnets = flatten([
    for k, v in local.vpc[var.environment] : [
      for idx, subnet in v[2] : {
        vpc_key    = k
        region     = v[0]
        cidr_block = subnet
        az         = "${v[0]}${element(["a", "b", "c", "d"], idx)}"
      }
    ]
  ])
  # Give the subnet a unique key
  subnet_map = {
    for subnet in local.flattened_subnets : "${subnet.vpc_key}-${subnet.az}" => subnet
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
      some_public_route = ["eu-west-1", "interface", "192.168.0.0/16"]
      some_aws_route    = ["eu-west-1", "gateway", "10.0.2.0/23"]
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

  # Flatten the structure for route creation
  flattened_ec2_subnet_routes = length(local.flattened_ec2_subnet) > 0 ? flatten([
    for ec2_subnet in local.flattened_ec2_subnet : [
      for route_key, route in local.public_routes[var.environment] : {
        vpc_key      = ec2_subnet.vpc_key
        ec2_key      = ec2_subnet.ec2_key
        rt_key       = ec2_subnet.rt_key
        route_key    = route_key
        route_region = route[0]
        route_target = route[1]
        route_cidr   = route[2]
        az           = ec2_subnet.ec2_az
      }
    ]
  ]) : []

  ec2_subnet_routes_map = {
    for idx, route in local.flattened_ec2_subnet_routes : "${route.route_key}-${route.az}" => route
  }
}

output "ec2_subnet_routes_map" {
  value = local.ec2_subnet_routes_map
}

resource "aws_route" "public_interface_route_dub" {
  for_each = {
    for idx, route in local.ec2_subnet_routes_map : idx => route
    if route.route_target == "interface" && route.route_region == "eu-west-1"
  }
  provider               = aws.dublin
  route_table_id         = aws_route_table.public_dub[each.value.rt_key].id
  destination_cidr_block = each.value.route_cidr
  network_interface_id   = aws_instance.ec2_dub[each.value.ec2_key].primary_network_interface_id
}

resource "aws_route" "public_gateway_route_dub" {
  for_each = {
    for idx, route in local.ec2_subnet_routes_map : idx => route
    if route.route_target == "gateway" && route.route_region == "eu-west-1"
  }
  provider               = aws.dublin
  route_table_id         = aws_route_table.public_dub[each.value.rt_key].id
  destination_cidr_block = each.value.route_cidr
  gateway_id             = aws_internet_gateway.igw_dub[each.value.vpc_key].id
}