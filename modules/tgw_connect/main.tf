# Create TGW connect attachnment
# - Create attachement connect to vpc FGT
# - Create peer to FGT active
# - Create peer to FGT passive
resource "aws_ec2_transit_gateway_connect" "tgw_connect" {
  for_each = { for i, v in var.peers : i => v["id"] if i <= var.max_connect_attachment }

  transport_attachment_id = var.vpc_attachment_id
  transit_gateway_id      = var.tgw_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    { Name = "${var.prefix}-connect-${each.value}" },
    var.tags
  )
}
# Create TGW connect peer active
resource "aws_ec2_transit_gateway_connect_peer" "tgw_connect_peer" {
  for_each = { for i, v in var.peers : i => v if i <= var.max_connect_attachment }

  bgp_asn                       = each.value["fgt_bgp_asn"]
  peer_address                  = each.value["fgt_ip"]
  transit_gateway_address       = each.value["tgw_ip"]
  inside_cidr_blocks            = [each.value["inside_cidr"]]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.tgw_connect[each.key].id

  tags = merge(
    { Name = "${var.prefix}-peer-${each.value["id"]}" },
    var.tags
  )
}
# Create route table association
resource "aws_ec2_transit_gateway_route_table_association" "rt_association" {
  for_each = { for i, v in var.peers : i => v if i <= var.max_connect_attachment }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.tgw_connect[each.key].id
  transit_gateway_route_table_id = var.rt_association_id
}
locals {
  rt_propagations = flatten([
    for i, v in aws_ec2_transit_gateway_connect.tgw_connect : [
      for ii, vv in var.rt_propagation_ids : {
        "attch_id" = v.id,
        "rt_id"    = vv
      }
    ]
    ]
  )
}
# Create route propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "rt_propagation" {
  for_each = { for i, v in local.rt_propagations : i => v }

  transit_gateway_attachment_id  = each.value["attch_id"]
  transit_gateway_route_table_id = each.value["rt_id"]
}