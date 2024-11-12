#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "fgt-sdwan"

  tags = {
    Project = "ftnt_modules_aws"
  }

  region    = "eu-west-1"
  hub_azs   = ["eu-west-1a", "eu-west-1b"] //Select AZs to deploy HUB FortiGates (1 FGT peer AZ)
  spoke_azs = ["eu-west-1a"]               //Select AZs to deploy SDWAN FortiGates (1 FGT peer AZ)

  admin_port = "8443"
  //admin_cidr = "<customer-public-cidr>" #CIDR to be configured at SG for Management and Fortigate Trusted hosts
  admin_cidr    = "0.0.0.0/0"
  instance_type = "c6i.large"
  fgt_build     = "build2702"
  license_type  = "payg"


  #-----------------------------------------------------------------------------------------------------
  # CIDRs details
  #-----------------------------------------------------------------------------------------------------
  # HUB VPC - CIDR
  hub_vpc_cidr = "10.1.0.0/24"

  # TGW - CIDR
  tgw_cidr    = "10.1.10.0/24"
  tgw_bgp_asn = "65010"

  # SDWAN SPOKE (10.1.10x.0/24)
  sdwan_spoke_number = 2
  sdwan_spokes = { for i in range(0, local.sdwan_spoke_number) :
    "${i}" => {
      id      = "sdwan${i + 1}"
      cidr    = "10.1.${i + 101}.0/24"
      bgp_asn = "65000"
    }
  }

  # VPC SPOKE to TGW (10.1.20x.0/24)
  vpc_spoke_number = 2
  vpc_spokes = { for i in range(0, local.vpc_spoke_number) :
    "${i}" => {
      id   = "spoke${i + 1}"
      cidr = "10.1.${i + 201}.0/24"
    }
  }

  #-----------------------------------------------------------------------------------------------------
  # SDWAN VPN details
  #-----------------------------------------------------------------------------------------------------
  # VPN HUB variables
  hub_id       = "EMEA"
  hub_bgp_asn  = "65000"           // iBGP RR server
  hub_vpn_cidr = "172.16.100.0/24" // VPN DialUp spokes cidr
  hub_cidr     = "10.0.0.0/8"      // BGP advertised and routed to FGT HUB within AWS

}
