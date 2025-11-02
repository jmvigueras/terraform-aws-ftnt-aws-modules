# Example: Forigate deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
locals {

  azs                = ["eu-west-1a"] // List of AZs to deploy
  fgt_number_peer_az = 2              // choose number of fortigate instances to deploy peer AZ
  fgt_cluster_type   = "fgsp"         // choose type of cluster either fgsp or fgcp  

  # fgt_tags -> used in tag subnet names (these values are defined as default in module fgt_ni_sg)
  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha-sync"
  }

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - port1, port2 ... mach with fortigate instance ports
  # - public, private, mgmt ... are the values for tags choosen ih local.subnet_tags
  fgt_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "untrusted"
    "port2.${local.subnet_tags["private"]}" = "trusted"
    "port3.${local.subnet_tags["mgmt"]}"    = "mgmt" // leave blank or don't add this element to not create a MGMT port
    "port4.${local.subnet_tags["ha"]}"      = ""     // leave blank or don't add this element to not create a HA port
  }

  # VPC - list of public and private subnet names (include names selected in local.fgt_subnet_tags)
  public_subnet_names  = [local.fgt_subnet_tags["port1.public"], local.fgt_subnet_tags["port3.mgmt"], "bastion"]
  private_subnet_names = [local.fgt_subnet_tags["port2.private"], local.fgt_subnet_tags["port4.ha-sync"], "tgw", "gwlb"]
}

module "example" {
  source = "../fgt"

  prefix   = local.prefix
  keypair  = "eu-west-1-key-name"
  
  fgt_ni_list   = local.fgt_ni_list
  fgt_config    = local.fgt_config

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build1575"
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

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
| <a name="module_ns_fgt_private_routes_to_tgw"></a> [ns\_fgt\_private\_routes\_to\_tgw](#module\_ns\_fgt\_private\_routes\_to\_tgw) | ../../modules/vpc_routes | n/a |
| <a name="module_ns_tgw_vpc_routes_to_fgt_ni"></a> [ns\_tgw\_vpc\_routes\_to\_fgt\_ni](#module\_ns\_tgw\_vpc\_routes\_to\_fgt\_ni) | ../../modules/vpc_routes | n/a |
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ../../modules/tgw | n/a |
| <a name="module_tgw_attachment"></a> [tgw\_attachment](#module\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.ssh_private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt_ids"></a> [fgt\_ids](#output\_fgt\_ids) | ----------------------------------------------------------------------------------------------------- Outputs ----------------------------------------------------------------------------------------------------- |
| <a name="output_fgt_ni_list"></a> [fgt\_ni\_list](#output\_fgt\_ni\_list) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.