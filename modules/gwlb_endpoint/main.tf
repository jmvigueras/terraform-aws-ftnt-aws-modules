#---------------------------------------------------------------------------
# GWLB
# - Create Endpoint Service
#---------------------------------------------------------------------------
// Create VPC endpoints GWLB
resource "aws_vpc_endpoint" "gwlb_endpoints" {
  count             = length(var.subnet_ids)
  service_name      = var.gwlb_service_name
  subnet_ids        = [var.subnet_ids[count.index]]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = var.vpc_id

  tags = merge(
    { Name = "${var.prefix}-gwlb-endpoint-az${count.index + 1}"},
    var.tags
  )
}



