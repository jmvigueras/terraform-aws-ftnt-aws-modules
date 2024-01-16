output "gwlb_endpoints" {
  description = "IDs of GWLB endpoint created"
  value = aws_vpc_endpoint.gwlb_endpoints.*.id
}