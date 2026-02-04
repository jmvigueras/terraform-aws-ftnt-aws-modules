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
# Example 1: FGT cluster FGCP in 1 AZ with 2 members

module "fgt-cluster-fgcp-1az" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-security-vpc"
  version = "1.0.16"

  prefix = "fgt-cluster-fgcp-1az"

  region = "eu-west-1"
  azs    = ["eu-west-1a"]

  fgt_number_peer_az = 2
  fgt_cluster_type = "fgcp"

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build2795"

  fgt_vpc_cidr = "10.10.0.0/24"

  public_subnet_names_extra = ["bastion"]
  private_subnet_names_extra = ["tgw","protected"]
}

# Example 2: FGT cluster FGCP in 2 AZ with 2 members
 
module "fgt-cluster-fgcp-2az" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-security-vpc"
  version = "1.0.16"

  prefix = "fgt-cluster-fgcp-1az"

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"]

  fgt_number_peer_az = 1
  fgt_cluster_type = "fgcp"

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build2795"

  fgt_vpc_cidr = "10.10.0.0/24"

  public_subnet_names_extra = ["bastion"]
  private_subnet_names_extra = ["tgw","protected"]
}

# Example 3: FGT cluster FGSP in 3 AZ with 3 members with GWLB
 
module "fgt-cluster-fgsp-3az" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-security-vpc"
  version = "1.0.16"

  prefix = "fgt-cluster-fgsp-3az"

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  fgt_number_peer_az = 1
  fgt_cluster_type = "fgsp"

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build2795"

  fgt_vpc_cidr = "10.10.0.0/23"

  config_gwlb = true
}

# Example 4: FGT cluster FGSP with GWLB
 
module "fgt-cluster-fgsp-1az" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-security-vpc"
  version = "1.0.16"

  prefix = "fgt-cluster-fgcp-1az"

  region = "eu-west-1"
  azs    = ["eu-west-1a"]

  fgt_number_peer_az = 2
  fgt_cluster_type = "fgsp"

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build2795"

  fgt_vpc_cidr = "10.10.0.0/24"

  config_gwlb = true
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dmz_vm"></a> [dmz\_vm](#module\_dmz\_vm) | ../../modules/vm | n/a |
| <a name="module_fgt"></a> [fgt](#module\_fgt) | ../../modules/fgt_sec_vpc_ipv46 | n/a |
| <a name="module_fgt_private_routes_to_tgw"></a> [fgt\_private\_routes\_to\_tgw](#module\_fgt\_private\_routes\_to\_tgw) | ../../modules/vpc_routes_ipv46 | n/a |
| <a name="module_fgt_vpc_tgw_attachment"></a> [fgt\_vpc\_tgw\_attachment](#module\_fgt\_vpc\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_spoke_private_routes_to_tgw"></a> [spoke\_private\_routes\_to\_tgw](#module\_spoke\_private\_routes\_to\_tgw) | ../../modules/vpc_routes_ipv46 | n/a |
| <a name="module_spoke_vm"></a> [spoke\_vm](#module\_spoke\_vm) | ../../modules/vm | n/a |
| <a name="module_spoke_vpc"></a> [spoke\_vpc](#module\_spoke\_vpc) | ../../modules/vpc_ipv46 | n/a |
| <a name="module_spoke_vpc_tgw_attachment"></a> [spoke\_vpc\_tgw\_attachment](#module\_spoke\_vpc\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ../../modules/tgw | n/a |
| <a name="module_tgw_private_routes_to_fgt"></a> [tgw\_private\_routes\_to\_fgt](#module\_tgw\_private\_routes\_to\_fgt) | ../../modules/vpc_routes_ipv46 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_route.pre_inspection_routes_to_fgt_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.pre_inspection_routes_to_fgt_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [local_file.ssh_private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_vars"></a> [custom\_vars](#input\_custom\_vars) | Custom variables | <pre>object({<br/>    prefix                     = optional(string, "fgt-vpc-sec")<br/>    region                     = optional(string, "eu-west-1")<br/>    number_azs                 = optional(number, 2)<br/>    fgt_number_peer_az         = optional(number, 1)<br/>    fgt_build                  = optional(string, "build3652")<br/>    license_type               = optional(string, "payg")<br/>    fortiflex_tokens           = optional(list(string), [])<br/>    fgt_size                   = optional(string, "c6i.xlarge")<br/>    fgt_cluster_type           = optional(string, "fgcp")<br/>    fgt_vpc_cidr               = optional(string, "172.16.0.0/24")<br/>    public_subnet_names_extra  = optional(list(string), [])<br/>    private_subnet_names_extra = optional(list(string), ["tgw", "dmz"])<br/>    config_mgmt_nat_gateway    = optional(bool, false)<br/>    config_mgmt_private        = optional(bool, false)<br/>    config_gwlb                = optional(bool, false)<br/>    tgw_cidr                   = optional(string, "172.16.10.0/24")<br/>    tgw_bgp_asn                = optional(number, 65000)<br/>    spoke_vpc_cidr             = optional(string, "172.16.20.0/24")<br/>    tags = optional(map(string), {<br/>      "Deploy"  = "Fortigate Security VPC"<br/>      "Project" = "Fortigate Terraform AWS Modules"<br/>    })<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug_vpc_rt_ids"></a> [debug\_vpc\_rt\_ids](#output\_debug\_vpc\_rt\_ids) | n/a |
| <a name="output_debug_vpc_subnet_cidrs"></a> [debug\_vpc\_subnet\_cidrs](#output\_debug\_vpc\_subnet\_cidrs) | ------------------------------------------------------------------------------------------------------------- Debugging Outputs ------------------------------------------------------------------------------------------------------------- |
| <a name="output_fgt"></a> [fgt](#output\_fgt) | ------------------------------------------------------------------------------------------------------------- Outputs ------------------------------------------------------------------------------------------------------------- |
| <a name="output_fgt_api_key"></a> [fgt\_api\_key](#output\_fgt\_api\_key) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.