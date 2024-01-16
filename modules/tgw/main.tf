#------------------------------------------------------------------------------------------------------------
# TRANSIT GATEWAY
# - Create TGW
# - Create RouteTables
#------------------------------------------------------------------------------------------------------------
locals {
  transit_gateway_cidr_blocks = [var.tgw_cidr]
}

# Create TGW
resource "aws_ec2_transit_gateway" "tgw" {
  description                 = "${var.prefix} TGW"
  transit_gateway_cidr_blocks = local.transit_gateway_cidr_blocks
  amazon_side_asn             = var.tgw_bgp_asn

  tags = merge(
    {Name = "${var.prefix}-tgw"},
    var.tags
  )
}
# Create Route Tables
// RT pre inspection (vpc spokes)
resource "aws_ec2_transit_gateway_route_table" "rt_pre_inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = merge(
    {Name = "${var.prefix}-rt-pre-inspection"},
    var.tags
  )
}
// RT post inspection (FGT)
resource "aws_ec2_transit_gateway_route_table" "rt_post_inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = merge(
    {Name = "${var.prefix}-rt-post-inspection"},
    var.tags
  )
}

