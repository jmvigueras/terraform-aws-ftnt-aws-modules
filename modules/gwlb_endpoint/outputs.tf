output "gwlb_endpoints" {
  description = "Map of IDs of GWLB endpoint created"
  value       = { for k, v in aws_vpc_endpoint.gwlb_endpoints : k => v.id }
}