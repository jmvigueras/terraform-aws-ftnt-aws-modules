# Locals for generate resources
locals {
  ni_id      = var.ni_id != null ? var.ni_id : one(aws_network_interface.ni.*.id)
  private_ip = var.private_ip != null ? var.private_ip : cidrhost(var.subnet_cidr, var.cidr_host)
  # Outputs
  public_ip = var.config_eip ? one(aws_eip.eip.*.public_ip) : ""
}

# Get current region
data "aws_region" "current" {}

/*
# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fac_amis_payg" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiAnalyzer-VM64-AWSONDEMAND ${var.fac_build}*"]
  }
}
data "aws_ami_ids" "fac_amis_byol" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiAnalyzer-VM64-AWS ${var.fac_build}*"]
  }
}
*/

