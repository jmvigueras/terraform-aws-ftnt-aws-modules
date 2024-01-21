#---------------------------------------------------------------------------
# GWLB
# - Create Endpoint Service
#---------------------------------------------------------------------------
// Create VPC endpoints GWLB
resource "aws_vpc_endpoint" "gwlb_endpoints" {
  for_each = var.subnet_ids

  service_name      = var.gwlb_service_name
  subnet_ids        = [each.value]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = var.vpc_id

  tags = merge(
    { Name = "${var.prefix}-gwlbe-${each.key}" },
    var.tags
  )
}



