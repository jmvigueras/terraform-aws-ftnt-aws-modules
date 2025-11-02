# Example: FortiAuthenticator deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
locals {
  # fac - details
  fac_instance_type = "r5.xlarge"

  # fac - Number of instances peer AZ
  fac_number_peer_az = 1

  # fac - VPC details
  fac_vpc_cidr             = "10.1.10.0/24"
  fac_public_subnet_names  = ["vm"]
  fac_private_subnet_names = ["tgw", "nlb"]
}

module "example" {
  source = "../../modules/fac"

  prefix        = "fac"
  keypair       = "key-name-pair"
  instance_type = local.fac_instance_type

  subnet_id       = "subnet-xxxx"
  subnet_cidr     = "10.10.0.0/24"
  security_groups = [sg-xxxx]

  license_type = "payg"
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
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fac"></a> [fac](#module\_fac) | ../../modules/fac | n/a |
| <a name="module_fac_vpc"></a> [fac\_vpc](#module\_fac\_vpc) | ../../modules/vpc | n/a |
| <a name="module_nlb"></a> [nlb](#module\_nlb) | ../../modules/nlb | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.ssh_private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [http_http.my-public-ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Access and secret keys to your environment | `any` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fac_ids"></a> [fac\_ids](#output\_fac\_ids) | ----------------------------------------------------------------------------------------------------- Outputs ----------------------------------------------------------------------------------------------------- |
| <a name="output_fac_private_ips"></a> [fac\_private\_ips](#output\_fac\_private\_ips) | n/a |
| <a name="output_fac_public_ips"></a> [fac\_public\_ips](#output\_fac\_public\_ips) | n/a |
| <a name="output_nlb"></a> [nlb](#output\_nlb) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.