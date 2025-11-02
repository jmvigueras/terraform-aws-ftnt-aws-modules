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
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-cluster-fgcp-1az"
  version = "1.0.4"

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
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-cluster-fgcp-1az"
  version = "1.0.4"

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
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-cluster-fgcp-1az"
  version = "1.0.4"

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
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-cluster-fgcp-1az"
  version = "1.0.4"

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fgt"></a> [fgt](#module\_fgt) | ../../modules/fgt | n/a |
| <a name="module_fgt_config"></a> [fgt\_config](#module\_fgt\_config) | ../../modules/fgt_config | n/a |
| <a name="module_fgt_nis"></a> [fgt\_nis](#module\_fgt\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_fgt_vpc"></a> [fgt\_vpc](#module\_fgt\_vpc) | ../../modules/vpc | n/a |
| <a name="module_gwlb"></a> [gwlb](#module\_gwlb) | ../../modules/gwlb | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_gw_mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_key_pair.keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_nat_gateway.nat_gw_mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.nat_gw_mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [local_file.ssh_private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | value of admin\_cidr | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | value of admin\_port | `string` | `"8443"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | AWS access key | `list(string)` | <pre>[<br/>  "eu-west-1a",<br/>  "eu-west-1b"<br/>]</pre> | no |
| <a name="input_config_extra"></a> [config\_extra](#input\_config\_extra) | Add extra config to bootstrap config generated | `string` | `""` | no |
| <a name="input_config_gwlb"></a> [config\_gwlb](#input\_config\_gwlb) | Boolean to enable deploymen of and GWLB | `bool` | `false` | no |
| <a name="input_config_mgmt_nat_gateway"></a> [config\_mgmt\_nat\_gateway](#input\_config\_mgmt\_nat\_gateway) | Boolean to deploy NAT gateway for management interface has Internet access (mandatory if cluster type is FGCP and config\_mgmt\_private is true) | `bool` | `false` | no |
| <a name="input_config_mgmt_private"></a> [config\_mgmt\_private](#input\_config\_mgmt\_private) | Boolean to deploy Management interface private (if cluster type is FGCP this interfaces needs Internet access) | `bool` | `false` | no |
| <a name="input_fgt_api_key"></a> [fgt\_api\_key](#input\_fgt\_api\_key) | API key for FGTs | `string` | `null` | no |
| <a name="input_fgt_build"></a> [fgt\_build](#input\_fgt\_build) | value of FortiOS build | `string` | `"build2795"` | no |
| <a name="input_fgt_cluster_type"></a> [fgt\_cluster\_type](#input\_fgt\_cluster\_type) | value of fgt\_cluster\_type | `string` | `"fgcp"` | no |
| <a name="input_fgt_number_peer_az"></a> [fgt\_number\_peer\_az](#input\_fgt\_number\_peer\_az) | value of fgt\_number\_peer\_az | `number` | `1` | no |
| <a name="input_fgt_subnet_tags"></a> [fgt\_subnet\_tags](#input\_fgt\_subnet\_tags) | fgt\_subnet\_tags -> add tags to FGT subnets (port1, port2, public, private ...)<br/>        - leave blank or don't add elements to not create a ports<br/>        - FGCP type of cluster requires a management port<br/>        - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. | `map(string)` | `null` | no |
| <a name="input_fgt_vpc_cidr"></a> [fgt\_vpc\_cidr](#input\_fgt\_vpc\_cidr) | VPC - CIDR | `string` | `"10.1.0.0/24"` | no |
| <a name="input_fortiflex_tokens"></a> [fortiflex\_tokens](#input\_fortiflex\_tokens) | List of FortiFlex tokens to be used in the FortiGates | `list(string)` | `[]` | no |
| <a name="input_inspection_vpc_cidrs"></a> [inspection\_vpc\_cidrs](#input\_inspection\_vpc\_cidrs) | list of CIDRs for inspection (used in GWLB) | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16"<br/>]</pre> | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | value of api\_token | `string` | `"c6i.large"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | value of license\_type | `string` | `"payg"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Objects prefix | `string` | `"fgt-cluster"` | no |
| <a name="input_private_subnet_names_extra"></a> [private\_subnet\_names\_extra](#input\_private\_subnet\_names\_extra) | VPC - list of additional private subnet names | `list(string)` | <pre>[<br/>  "tgw"<br/>]</pre> | no |
| <a name="input_public_subnet_names_extra"></a> [public\_subnet\_names\_extra](#input\_public\_subnet\_names\_extra) | VPC - list of additional public subnet names | `list(string)` | <pre>[<br/>  "bastion"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-west-1"` | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | map tags used in fgt\_subnet\_tags to tag subnet names | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | value of tags | `map(string)` | <pre>{<br/>  "Project": "ftnt_modules_aws"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | n/a |
| <a name="output_fgt"></a> [fgt](#output\_fgt) | ----------------------------------------------------------------------------------------------------- Outputs ----------------------------------------------------------------------------------------------------- |
| <a name="output_fgt_ids_map"></a> [fgt\_ids\_map](#output\_fgt\_ids\_map) | n/a |
| <a name="output_fgt_ni_list"></a> [fgt\_ni\_list](#output\_fgt\_ni\_list) | n/a |
| <a name="output_keypair_name"></a> [keypair\_name](#output\_keypair\_name) | n/a |
| <a name="output_rt_ids"></a> [rt\_ids](#output\_rt\_ids) | n/a |
| <a name="output_sg_ids"></a> [sg\_ids](#output\_sg\_ids) | n/a |
| <a name="output_ssh_private_key_pem"></a> [ssh\_private\_key\_pem](#output\_ssh\_private\_key\_pem) | n/a |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_subnet_private_cidrs"></a> [subnet\_private\_cidrs](#output\_subnet\_private\_cidrs) | n/a |
| <a name="output_subnet_private_ids"></a> [subnet\_private\_ids](#output\_subnet\_private\_ids) | n/a |
| <a name="output_subnet_public_cidrs"></a> [subnet\_public\_cidrs](#output\_subnet\_public\_cidrs) | n/a |
| <a name="output_subnet_public_ids"></a> [subnet\_public\_ids](#output\_subnet\_public\_ids) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.