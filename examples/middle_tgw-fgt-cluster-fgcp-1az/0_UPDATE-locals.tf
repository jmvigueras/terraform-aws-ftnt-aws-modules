#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "fgt-cluster"

  tags = {
    Project = "ftnt_modules_aws"
  }

  region = "eu-west-1"
  azs    = ["eu-west-1a"] //Select AZs to deploy

  admin_port = "8443"
  //admin_cidr = "<customer-public-cidr>" #CIDR to be configured at SG for Management and Fortigate Trusted hosts
  admin_cidr    = "0.0.0.0/0"
  instance_type = "c6i.large"
  fgt_build     = "build2795"
  license_type  = "payg"

  fgt_number_peer_az = 2
  fgt_cluster_type   = "fgcp" // choose type of cluster either fgsp or fgcp  

  # fgt_tags -> map tags used in fgt_subnet_tags to tag subnet names (this valued are define in modules as default)
  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha-sync"
  }

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - leave blank or don't add elements to not create a ports
  # - FGCP type of cluster requires a management port
  # - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. 
  fgt_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "untrusted"
    "port2.${local.subnet_tags["private"]}" = "trusted"
    "port3.${local.subnet_tags["mgmt"]}"    = "mgmt"
    "port4.${local.subnet_tags["ha"]}"      = ""
  }

  # VPC - list of public and private subnet names
  public_subnet_names  = [local.fgt_subnet_tags["port1.public"], local.fgt_subnet_tags["port3.mgmt"], "bastion"]
  private_subnet_names = [local.fgt_subnet_tags["port2.private"], local.fgt_subnet_tags["port4.ha-sync"], "tgw"]

  # VPC - CIDR
  fgt_vpc_cidr = "10.1.0.0/24"

  # TGW - CIDR
  tgw_cidr    = "10.1.10.0/24"
  tgw_bgp_asn = "65002"

}
