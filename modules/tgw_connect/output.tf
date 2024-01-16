output "id" {
  description = "List of ID of the AWS Transit Gateway VPC Attachment connect"
  value = [for k, v in aws_ec2_transit_gateway_connect.tgw_connect : v.id]
}