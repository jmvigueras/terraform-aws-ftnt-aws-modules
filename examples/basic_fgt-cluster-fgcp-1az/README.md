# Example: Forigate deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

```hcl

module "fgt-cluster-fgcp-1az" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-cluster-fgcp-1az"
  version = "0.0.9"

  prefix = "fgt-cluster-fgcp-1az"

  region = "eu-west-1"
  azs    = ["eu-west-1a"]

  fgt_number_peer_az = 2
  fgt_cluster_type = "fgcp"

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build2726"

  fgt_vpc_cidr = "10.10.0.0/24"

  public_subnet_names_extra = ["bastion"]
  private_subnet_names_extra = ["tgw", "gwlb", "protected"]
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

## Deployment

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.


