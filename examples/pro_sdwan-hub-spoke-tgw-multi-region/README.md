# Example: Forigate AWS Transit Gateway integration

Example of integration Fortinet SDWAN and AWS Transit Gateway in a global deployment. 
## Deployment Overview

This example deploys a multi-region Fortinet SD‑WAN design integrated with AWS Transit Gateway (TGW) using a hub-and-spoke topology. It demonstrates:
- Per-region TGW and VPCs (EU and US) with hub VPCs hosting FortiGate (FGT) instances.
- Spoke VPCs attached to regional TGWs; TGWs peered between regions for inter‑region traffic.
- FortiGate instances deployed as HA pairs in hub VPCs and as individual instances in spoke sites where applicable.
- TGW attachments, route tables, and VPC route propagation to steer traffic through FortiGate hubs.
- DNS-based VPN FQDNs with Route53 health checks, automated config artifacts, SSH key material, and generated secrets (PSK, API keys).

Architecture highlights
- Centralized inspection and routing in regional hubs; east‑west traffic between regions travels over TGW peering and is inspected at hubs.
- Modular layout: fgt, fgt_config, vpc, vpc_routes, tgw, tgw_attachment modules keep resources reusable and clear.
- Automated configuration support and health checks to enable resilient VPN and SD‑WAN behavior.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eu_hub"></a> [eu\_hub](#module\_eu\_hub) | ../../modules/fgt | n/a |
| <a name="module_eu_hub_config"></a> [eu\_hub\_config](#module\_eu\_hub\_config) | ../../modules/fgt_config | n/a |
| <a name="module_eu_hub_nis"></a> [eu\_hub\_nis](#module\_eu\_hub\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_eu_hub_vm"></a> [eu\_hub\_vm](#module\_eu\_hub\_vm) | ../../modules/vm | n/a |
| <a name="module_eu_hub_vpc"></a> [eu\_hub\_vpc](#module\_eu\_hub\_vpc) | ../../modules/vpc | n/a |
| <a name="module_eu_hub_vpc_routes"></a> [eu\_hub\_vpc\_routes](#module\_eu\_hub\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_eu_hub_vpc_tgw_attachment"></a> [eu\_hub\_vpc\_tgw\_attachment](#module\_eu\_hub\_vpc\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_eu_hub_vpc_tgw_connect"></a> [eu\_hub\_vpc\_tgw\_connect](#module\_eu\_hub\_vpc\_tgw\_connect) | ../../modules/tgw_connect | n/a |
| <a name="module_eu_op"></a> [eu\_op](#module\_eu\_op) | ../../modules/fgt | n/a |
| <a name="module_eu_op_config"></a> [eu\_op\_config](#module\_eu\_op\_config) | ../../modules/fgt_config | n/a |
| <a name="module_eu_op_nis"></a> [eu\_op\_nis](#module\_eu\_op\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_eu_op_vm"></a> [eu\_op\_vm](#module\_eu\_op\_vm) | ../../modules/vm | n/a |
| <a name="module_eu_op_vpc"></a> [eu\_op\_vpc](#module\_eu\_op\_vpc) | ../../modules/vpc | n/a |
| <a name="module_eu_op_vpc_routes"></a> [eu\_op\_vpc\_routes](#module\_eu\_op\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_eu_op_vpc_tgw_attachment"></a> [eu\_op\_vpc\_tgw\_attachment](#module\_eu\_op\_vpc\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_eu_sdwan"></a> [eu\_sdwan](#module\_eu\_sdwan) | ../../modules/fgt | n/a |
| <a name="module_eu_sdwan_config"></a> [eu\_sdwan\_config](#module\_eu\_sdwan\_config) | ../../modules/fgt_config | n/a |
| <a name="module_eu_sdwan_nis"></a> [eu\_sdwan\_nis](#module\_eu\_sdwan\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_eu_sdwan_vm"></a> [eu\_sdwan\_vm](#module\_eu\_sdwan\_vm) | ../../modules/vm | n/a |
| <a name="module_eu_sdwan_vpc"></a> [eu\_sdwan\_vpc](#module\_eu\_sdwan\_vpc) | ../../modules/vpc | n/a |
| <a name="module_eu_sdwan_vpc_routes"></a> [eu\_sdwan\_vpc\_routes](#module\_eu\_sdwan\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_eu_spoke_to_tgw"></a> [eu\_spoke\_to\_tgw](#module\_eu\_spoke\_to\_tgw) | ../../modules/vpc | n/a |
| <a name="module_eu_spoke_to_tgw_attachment"></a> [eu\_spoke\_to\_tgw\_attachment](#module\_eu\_spoke\_to\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_eu_spoke_to_tgw_routes"></a> [eu\_spoke\_to\_tgw\_routes](#module\_eu\_spoke\_to\_tgw\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_eu_spoke_to_tgw_vm"></a> [eu\_spoke\_to\_tgw\_vm](#module\_eu\_spoke\_to\_tgw\_vm) | ../../modules/vm | n/a |
| <a name="module_eu_tgw"></a> [eu\_tgw](#module\_eu\_tgw) | ../../modules/tgw | n/a |
| <a name="module_us_hub"></a> [us\_hub](#module\_us\_hub) | ../../modules/fgt | n/a |
| <a name="module_us_hub_config"></a> [us\_hub\_config](#module\_us\_hub\_config) | ../../modules/fgt_config | n/a |
| <a name="module_us_hub_nis"></a> [us\_hub\_nis](#module\_us\_hub\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_us_hub_vm"></a> [us\_hub\_vm](#module\_us\_hub\_vm) | ../../modules/vm | n/a |
| <a name="module_us_hub_vpc"></a> [us\_hub\_vpc](#module\_us\_hub\_vpc) | ../../modules/vpc | n/a |
| <a name="module_us_hub_vpc_routes"></a> [us\_hub\_vpc\_routes](#module\_us\_hub\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_us_hub_vpc_tgw_attachment"></a> [us\_hub\_vpc\_tgw\_attachment](#module\_us\_hub\_vpc\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_us_sdwan"></a> [us\_sdwan](#module\_us\_sdwan) | ../../modules/fgt | n/a |
| <a name="module_us_sdwan_config"></a> [us\_sdwan\_config](#module\_us\_sdwan\_config) | ../../modules/fgt_config | n/a |
| <a name="module_us_sdwan_nis"></a> [us\_sdwan\_nis](#module\_us\_sdwan\_nis) | ../../modules/fgt_ni_sg | n/a |
| <a name="module_us_sdwan_vm"></a> [us\_sdwan\_vm](#module\_us\_sdwan\_vm) | ../../modules/vm | n/a |
| <a name="module_us_sdwan_vpc"></a> [us\_sdwan\_vpc](#module\_us\_sdwan\_vpc) | ../../modules/vpc | n/a |
| <a name="module_us_sdwan_vpc_routes"></a> [us\_sdwan\_vpc\_routes](#module\_us\_sdwan\_vpc\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_us_spoke_to_tgw"></a> [us\_spoke\_to\_tgw](#module\_us\_spoke\_to\_tgw) | ../../modules/vpc | n/a |
| <a name="module_us_spoke_to_tgw_attachment"></a> [us\_spoke\_to\_tgw\_attachment](#module\_us\_spoke\_to\_tgw\_attachment) | ../../modules/tgw_attachment | n/a |
| <a name="module_us_spoke_to_tgw_routes"></a> [us\_spoke\_to\_tgw\_routes](#module\_us\_spoke\_to\_tgw\_routes) | ../../modules/vpc_routes | n/a |
| <a name="module_us_spoke_to_tgw_vm"></a> [us\_spoke\_to\_tgw\_vm](#module\_us\_spoke\_to\_tgw\_vm) | ../../modules/vm | n/a |
| <a name="module_us_tgw"></a> [us\_tgw](#module\_us\_tgw) | ../../modules/tgw | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_peering_attachment.tgw_peer_eu_us](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_route.eu_tgw_route_to_us_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.us_tgw_route_default_to_hub_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_key_pair.eu_keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_key_pair.us_keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_health_check.eu_hub_vpn_fqdn_hck_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_health_check.eu_hub_vpn_fqdn_hcks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_health_check.eu_op_vpn_fqdn_hck_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_health_check.eu_op_vpn_fqdn_hcks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_health_check.us_op_vpn_fqdn_hck_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_health_check.us_op_vpn_fqdn_hcks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_record.eu_hub_vpn_fqdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.eu_hub_vpn_fqdn_fgts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.eu_op_vpn_fqdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.eu_op_vpn_fqdn_fgts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.us_op_vpn_fqdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.us_op_vpn_fqdn_fgts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [local_file.ssh_private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.vpn_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_route53_zone.route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [http_http.my-public-ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Access and secret keys to your environment | `any` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eu_hub_ids"></a> [eu\_hub\_ids](#output\_eu\_hub\_ids) | ----------------------------------------------------------------------------------------------------- EU - EMEA HUB ----------------------------------------------------------------------------------------------------- |
| <a name="output_eu_hub_ni_list"></a> [eu\_hub\_ni\_list](#output\_eu\_hub\_ni\_list) | n/a |
| <a name="output_eu_hub_vm"></a> [eu\_hub\_vm](#output\_eu\_hub\_vm) | n/a |
| <a name="output_eu_op_ids"></a> [eu\_op\_ids](#output\_eu\_op\_ids) | ----------------------------------------------------------------------------------------------------- HUB ON-PREMISES ----------------------------------------------------------------------------------------------------- |
| <a name="output_eu_op_ni_list"></a> [eu\_op\_ni\_list](#output\_eu\_op\_ni\_list) | n/a |
| <a name="output_eu_op_vm"></a> [eu\_op\_vm](#output\_eu\_op\_vm) | n/a |
| <a name="output_eu_sdwan_ids"></a> [eu\_sdwan\_ids](#output\_eu\_sdwan\_ids) | ----------------------------------------------------------------------------------------------------- EU SDWAN SPOKES ----------------------------------------------------------------------------------------------------- |
| <a name="output_eu_sdwan_ni_list"></a> [eu\_sdwan\_ni\_list](#output\_eu\_sdwan\_ni\_list) | n/a |
| <a name="output_eu_sdwan_vm"></a> [eu\_sdwan\_vm](#output\_eu\_sdwan\_vm) | n/a |
| <a name="output_eu_spoke_to_tgw_vm"></a> [eu\_spoke\_to\_tgw\_vm](#output\_eu\_spoke\_to\_tgw\_vm) | n/a |
| <a name="output_us_hub_ids"></a> [us\_hub\_ids](#output\_us\_hub\_ids) | ----------------------------------------------------------------------------------------------------- US - NORAM HUB ----------------------------------------------------------------------------------------------------- |
| <a name="output_us_hub_ni_list"></a> [us\_hub\_ni\_list](#output\_us\_hub\_ni\_list) | n/a |
| <a name="output_us_hub_vm"></a> [us\_hub\_vm](#output\_us\_hub\_vm) | n/a |
| <a name="output_us_sdwan_ids"></a> [us\_sdwan\_ids](#output\_us\_sdwan\_ids) | ----------------------------------------------------------------------------------------------------- US SDWAN SPOKES ----------------------------------------------------------------------------------------------------- |
| <a name="output_us_sdwan_ni_list"></a> [us\_sdwan\_ni\_list](#output\_us\_sdwan\_ni\_list) | n/a |
| <a name="output_us_sdwan_vm"></a> [us\_sdwan\_vm](#output\_us\_sdwan\_vm) | n/a |
| <a name="output_us_spoke_to_tgw_vm"></a> [us\_spoke\_to\_tgw\_vm](#output\_us\_spoke\_to\_tgw\_vm) | n/a |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.
