# Example: Forigate deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

You can choose type of cluster to deploy, number of AZs to deploy and number of FortiGate cluster members.

> [!NOTE]
> FGCP cluster has two members only and can be deployed in 1 or 2 AZs
> FGSP cluster can have up to 16 members, recommended no more than 8 and can be split in several AZs.

## Deployment Overview

This example demonstrates how to deploy FortiGate clusters on AWS using the `ftnt-aws-modules` Terraform module. The deployment supports both FGCP (FortiGate Clustering Protocol) and FGSP (FortiGate Session Sync Protocol) cluster types with flexible configuration options.

### Key Features

- **Multiple Cluster Types**: Support for both FGCP and FGSP clustering
- **Multi-AZ Deployment**: Deploy across 1-3 Availability Zones for high availability
- **Flexible Scaling**: Configure number of cluster members per AZ
- **Gateway Load Balancer**: Optional GWLB integration for centralized inspection
- **License Options**: Support for BYOL, PAYG, and FortiFlex licensing
- **Network Integration**: Configurable subnets for bastion, TGW, and protected networks

### Cluster Types

| Cluster Type | Max Members | AZ Support | Use Case |
|--------------|-------------|------------|----------|
| **FGCP** | 2 members | 1-2 AZs | Active-Passive clustering with session sync |
| **FGSP** | Up to 16 (recommended ≤8) | 1-3 AZs | Active-Active clustering for high throughput |

### Architecture Components

- **VPC**: Dedicated VPC with customizable CIDR ranges
- **Subnets**: Public/private subnets across multiple AZs
- **Security Groups**: Preconfigured security groups for FortiGate access
- **Network Interfaces**: Managed ENIs with appropriate security group associations
- **Key Pair**: Auto-generated SSH key pair for instance access
- **NAT Gateway**: Optional NAT gateway for private management access

## Module use

```hcl
# Call the module with 1 input "custom_vars"

module "fgt-vpc-sec" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-security-vpc_ipv46"
  version = "1.0.7"

  custom_vars = var.custom_vars
}

# custom_vars examples.

# Example 1: FGT cluster FGCP in 1 AZ with 2 members

custom_vars = {
  prefix      = optional(string, "fgt-sec-1az-fgcp")
  region      = optional(string, "eu-west-1")
  
  number_azs         = 1
  fgt_number_peer_az = 2

  license_type  = "byol"

  fgt_vpc_cidr = "10.10.0.0/24"
}

# Example 2: FGT cluster FGCP in 2 AZ with 2 members with no EIP at Management interface

custom_vars = {
  prefix      = optional(string, "fgt-sec-2az-fgcp")
  region      = optional(string, "eu-west-1")
  number_azs  = 2

  config_mgmt_nat_gateway = true
  config_mgmt_private     = true
}

# Example 3: FGT cluster FGSP in 3 AZ with 3 members

custom_vars = {
  prefix      = optional(string, "fgt-sec-2az-fgsp")
  region      = optional(string, "eu-west-1")
  number_azs  = 3

  fgt_cluster_type = "fgsp"
  fgt_size = "c6i.large"

  license_type  = "byol"

  config_gwlb = "true"
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fgt"></a> [fgt](#module\_fgt) | ../../modules/fgt_sec_vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_vars"></a> [custom\_vars](#input\_custom\_vars) | Custom variables | `map` | <pre>{<br/>  "azs": [<br/>    "eu-west-1a",<br/>    "eu-west-1b"<br/>  ],<br/>  "config_gwlb": false,<br/>  "config_mgmt_nat_gateway": false,<br/>  "config_mgmt_private": false,<br/>  "fgt_build": "build2795",<br/>  "fgt_cluster_type": "fgcp",<br/>  "fgt_number_peer_az": 1,<br/>  "fgt_size": "c6i.xlarge",<br/>  "fgt_vpc_cidr": "172.10.0.0/24",<br/>  "license_type": "byol",<br/>  "prefix": "fgt-vpc-sec",<br/>  "private_subnet_names_extra": [<br/>    "tgw"<br/>  ],<br/>  "public_subnet_names_extra": [],<br/>  "region": "eu-west-1",<br/>  "tags": {<br/>    "Deploy": "Fortigate PRO",<br/>    "Project": "Fortigate Produccion 2AZ"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt"></a> [fgt](#output\_fgt) | ------------------------------- Outputs ------------------------------- |
| <a name="output_fgt_api_key"></a> [fgt\_api\_key](#output\_fgt\_api\_key) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.