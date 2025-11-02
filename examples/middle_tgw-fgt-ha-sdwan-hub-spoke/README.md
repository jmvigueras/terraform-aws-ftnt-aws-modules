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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.75.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub"></a> [hub](#module\_hub) | ../../modules/fgt | n/a |
| <a name="module_hub_config"></a> [hub\_config](#module\_hub\_config) | ../../modules/fgt_config | n/a |
| <a name="module_hub_nis"></a> [hub\_nis](#module\_hub\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_hub_vpc"></a> [hub\_vpc](#module\_hub\_vpc) | ../../modules/vpc | n/a |
| <a name="module_ns_fgt_private_routes_to_tgw"></a> [ns\_fgt\_private\_routes\_to\_tgw](#module\_ns\_fgt\_private\_routes\_to\_tgw) | ../../modules/vpc_routes | n/a |
| <a name="module_ns_tgw_vpc_routes_to_fgt_ni"></a> [ns\_tgw\_vpc\_routes\_to\_fgt\_ni](#module\_ns\_tgw\_vpc\_routes\_to\_fgt\_ni) | ../../modules/vpc_routes | n/a |
| <a name="module_sdwan"></a> [sdwan](#module\_sdwan) | ../../modules/fgt | n/a |
| <a name="module_sdwan_config"></a> [sdwan\_config](#module\_sdwan\_config) | ../../modules/fgt_config | n/a |
| <a name="module_sdwan_nis"></a> [sdwan\_nis](#module\_sdwan\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_sdwan_vm"></a> [sdwan\_vm](#module\_sdwan\_vm) | ../../modules/vm | n/a |
| <a name="module_sdwan_vpc"></a> [sdwan\_vpc](#module\_sdwan\_vpc) | ../../modules/vpc | n/a |
| <a name="module_sdwan_vpc_routes"></a> [sdwan\_vpc\_routes](#module\_sdwan\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_spoke_vm"></a> [spoke\_vm](#module\_spoke\_vm) | ../../modules/vm | n/a |
| <a name="module_spoke_vpc"></a> [spoke\_vpc](#module\_spoke\_vpc) | ../../modules/vpc | n/a |
| <a name="module_spoke_vpc_routes"></a> [spoke\_vpc\_routes](#module\_spoke\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_spoke_vpc_tgw_attachment"></a> [spoke\_vpc\_tgw\_attachment](#module\_spoke\_vpc\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Access and secret keys to your environment | `any` | n/a | yes |
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | Admin CIDR to limit access to FortiGates and test VMs | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | Admin port to configure at FortiGates | `string` | `"8443"` | no |
| <a name="input_default_bgp_asn"></a> [default\_bgp\_asn](#input\_default\_bgp\_asn) | Default BGP | `string` | `"65000"` | no |
| <a name="input_default_fgt_build"></a> [default\_fgt\_build](#input\_default\_fgt\_build) | Default FortiGate version if not defined by input variable | `string` | `"build2795"` | no |
| <a name="input_default_fgt_instance"></a> [default\_fgt\_instance](#input\_default\_fgt\_instance) | Default FortiGate instance type | `string` | `"c6i.large"` | no |
| <a name="input_default_license_type"></a> [default\_license\_type](#input\_default\_license\_type) | Default FortiGate consume service model | `string` | `"payg"` | no |
| <a name="input_hub"></a> [hub](#input\_hub) | Details to deploy SDWAN HUB | `map(string)` | <pre>{<br/>  "bgp_asn": "65000",<br/>  "bgp_network": "10.0.0.0/8",<br/>  "fgt_build": "build2702",<br/>  "id": "hub",<br/>  "instance_type": "c6i.large",<br/>  "license_type": "payg",<br/>  "vpc_cidr": "10.1.0.0/24",<br/>  "vpn_cidr": "172.16.100.0/24"<br/>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to add to AWS resources names | `string` | `"fgt-sdwan"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `"eu-west-1"` | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `any` | n/a | yes |
| <a name="input_spoke_sdwan"></a> [spoke\_sdwan](#input\_spoke\_sdwan) | Details to deploy SDWAN SPOKES | `list(map(string))` | <pre>[<br/>  {<br/>    "bgp_asn": "65000",<br/>    "fgt_build": "build2702",<br/>    "id": "sdwan1",<br/>    "instance_type": "c6i.large",<br/>    "license_type": "payg",<br/>    "vpc_cidr": "10.1.101.0/24"<br/>  },<br/>  {<br/>    "bgp_asn": "65000",<br/>    "fgt_build": "build2702",<br/>    "id": "sdwan2",<br/>    "instance_type": "c6i.large",<br/>    "license_type": "payg",<br/>    "vpc_cidr": "10.1.102.0/24"<br/>  }<br/>]</pre> | no |
| <a name="input_spoke_vpc"></a> [spoke\_vpc](#input\_spoke\_vpc) | Details to deploy SPOKES VPC to TGW | `list(map(string))` | <pre>[<br/>  {<br/>    "id": "vpc1",<br/>    "vpc_cidr": "10.1.201.0/24"<br/>  },<br/>  {<br/>    "id": "vpc2",<br/>    "vpc_cidr": "10.1.202.0/24"<br/>  }<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to add to AWS resources | `map(string)` | <pre>{<br/>  "Project": "ftnt_modules_aws"<br/>}</pre> | no |
| <a name="input_tgw"></a> [tgw](#input\_tgw) | TGW data | `map(string)` | <pre>{<br/>  "bgp_asn": "65010",<br/>  "cidr": "10.1.10.0/24"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_mgmt"></a> [hub\_mgmt](#output\_hub\_mgmt) | ----------------------------------------------------------------------------------------------------- Outputs ----------------------------------------------------------------------------------------------------- |
| <a name="output_sdwan_mgmt"></a> [sdwan\_mgmt](#output\_sdwan\_mgmt) | n/a |
| <a name="output_sdwan_vms"></a> [sdwan\_vms](#output\_sdwan\_vms) | n/a |
| <a name="output_spoke_vms"></a> [spoke\_vms](#output\_spoke\_vms) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.