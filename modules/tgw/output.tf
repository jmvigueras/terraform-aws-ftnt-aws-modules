# Outputs
output "rt_default_id" {
  description = "ID of the association default route table"
  value = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}
output "rt_pre_inspection_id" {
  description = "ID of the route table pre-inspection"
  value = aws_ec2_transit_gateway_route_table.rt_pre_inspection.id
}
output "rt_post_inspection_id" {
  description = "ID of the route table post-inspection"
  value = aws_ec2_transit_gateway_route_table.rt_post_inspection.id
}
output "tgw_id" {
  description = "ID of the transit gateway "
  value = aws_ec2_transit_gateway.tgw.id
}
output "tgw_owner_id" {
  description = "Owner ID of the transit gateway"
  value = aws_ec2_transit_gateway.tgw.owner_id
}