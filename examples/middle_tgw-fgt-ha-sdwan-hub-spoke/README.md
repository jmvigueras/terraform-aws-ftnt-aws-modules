# Example: Forigate deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
locals {

  region    = "eu-west-1"
  hub_azs   = ["eu-west-1a", "eu-west-1b"] //Select AZs to deploy HUB FortiGates (1 FGT peer AZ)
  spoke_azs = ["eu-west-1a"]               //Select AZs to deploy SDWAN FortiGates (1 FGT peer AZ)

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
  vpc_spokes = { for i in range(0, local.sdwan_spoke_number) :
    "${i}" => {
      id   = "spoke${i + 1}"
      cidr = "10.1.${i + 201}.0/24"
    }
  }

  # VPN HUB variables
  hub_id       = "EMEA"
  hub_bgp_asn  = "65000"           // iBGP RR server
  hub_vpn_cidr = "172.16.100.0/24" // VPN DialUp spokes cidr
  hub_cidr     = "10.0.0.0/8"      // BGP advertised and routed to FGT HUB within AWS
  
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

## Deployment

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.


