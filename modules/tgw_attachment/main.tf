#---------------------------------------------------------------------------
# Create VPC attachment
# - Create TGW attachment
# - Associate to RT
# - Propagate to RT
#---------------------------------------------------------------------------
# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids             = var.tgw_subnet_ids
  transit_gateway_id     = var.tgw_id
  vpc_id                 = var.vpc_id
  appliance_mode_support = var.appliance_mode_support

  transit_gateway_default_route_table_association = var.default_rt_association
  transit_gateway_default_route_table_propagation = var.default_rt_propagation

  tags = merge(
    { Name = "${var.prefix}-vpc-attach" },
    var.tags
  )
}
# Create route table association
resource "aws_ec2_transit_gateway_route_table_association" "rt_association" {
  count = var.default_rt_association ? 0 : 1
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
  transit_gateway_route_table_id = var.rt_association_id
}
# Create route propagation if route table id provided
resource "aws_ec2_transit_gateway_route_table_propagation" "rt_propagation" {
  for_each = { for i, v in var.rt_propagation_ids : i => v }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
  transit_gateway_route_table_id = each.value
}