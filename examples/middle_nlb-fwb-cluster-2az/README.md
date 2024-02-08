# Example: FortiWEB deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
locals {
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

module "example" {
  source = "../../modules/fwb"

  prefix        = "fwb"
  keypair       = "key-name-pair"
  instance_type = local.fwb_instance_type

  subnet_id       = "subnet-xxxx"
  subnet_cidr     = "10.10.0.0/24"
  security_groups = [sg-xxxx]

  license_type = "payg"
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

## Deployment

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.


