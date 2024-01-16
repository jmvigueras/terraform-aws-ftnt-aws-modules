output "id" {
  description = "ID of the AWS Transit Gateway VPC Attachment"
  value = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}