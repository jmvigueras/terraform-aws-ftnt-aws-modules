# ------------------------------------------------------------------------------------
# Create VPC
# ------------------------------------------------------------------------------------
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Enable IPv6 if requested
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    { Name = "${var.prefix}-vpc" },
    var.tags
  )
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { Name = "${var.prefix}-igw" },
    var.tags
  )
}
# Subnets peer AZ with IPv6 support
resource "aws_subnet" "subnets" {
  for_each = local.subnets_map

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]

  assign_ipv6_address_on_creation = var.enable_ipv6
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, each.value["subnet_num"]) : null

  tags = merge(
    { Name = "${var.prefix}-${each.key}" },
    var.tags
  )
}
