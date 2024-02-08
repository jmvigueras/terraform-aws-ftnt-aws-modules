#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "fwb-nlb"

  tags = {
    Project = "ftnt_modules_aws"
  }

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] //Select AZs to deploy

  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"

  # FWB - details
  fwb_instance_type = "r5.xlarge"
  fwb_license_type  = "payg"
  fwb_version       = "7.4.0"

  # FWB - Number of instances peer AZ
  fwb_number_peer_az = 1

  # FWB - VPC details
  fwb_vpc_cidr             = "10.1.10.0/24"
  fwb_public_subnet_names  = ["vm"]
  fwb_private_subnet_names = ["tgw", "nlb"]

}
