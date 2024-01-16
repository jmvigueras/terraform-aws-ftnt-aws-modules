#---------------------------------------------------------------------------
# Crate Route Table private to a NI
#---------------------------------------------------------------------------
# Create routes to NI in RTs
resource "aws_route" "r_private_to_ni_rfc1918_a" {
  for_each = local.ni_rt_ids 

  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  network_interface_id   = var.ni_id
}
resource "aws_route" "r_private_to_ni_rfc1918_b" {
  for_each = local.ni_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  network_interface_id   = var.ni_id
}
resource "aws_route" "r_private_to_ni_rfc1918_c" {
  for_each = local.ni_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  network_interface_id   = var.ni_id
}
#---------------------------------------------------------------------------
# Crate Route Table private to a TGW
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_tgw_rfc1918_a" {
  for_each = var.tgw_rt_ids 

  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tgw_id
}
resource "aws_route" "r_private_to_tgw_rfc1918_b" {
  for_each = local.tgw_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.tgw_id
}
resource "aws_route" "r_private_to_tgw_rfc1918_c" {
  for_each = local.tgw_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = var.tgw_id
}
#---------------------------------------------------------------------------
# Crate Route Table private to a GWLBe
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_gwlb_rfc1918_a" {
  for_each = var.gwlb_rt_ids 

  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = var.gwlbe_id
}
resource "aws_route" "r_private_to_gwlb_rfc1918_b" {
  for_each = local.gwlb_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  vpc_endpoint_id        = var.gwlbe_id
}
resource "aws_route" "r_private_to_gwlb_rfc1918_c" {
  for_each = local.gwlb_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  vpc_endpoint_id        = var.gwlbe_id
}
#---------------------------------------------------------------------------
# Crate Route Table private to a Core Network
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_core_net_rfc1918_a" {
  for_each = local.core_network_rt_ids 

  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = var.core_network_arn
}
resource "aws_route" "r_private_to_core_net_rfc1918_b" {
  for_each = local.core_network_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  core_network_arn       = var.core_network_arn
}
resource "aws_route" "r_private_to_core_net_rfc1918_c" {
  for_each = local.core_network_rt_ids

  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  core_network_arn       = var.core_network_arn
}
