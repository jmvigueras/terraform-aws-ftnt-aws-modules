# Terraform Module: FortiADC

## Description

Create FortiADC instance.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"
}

module "example" {
  source = "../fac"

  prefix          = "${local.prefix}"
  keypair         = aws_key_pair.keypair.key_name
  instance_type   = "c4.2xlarge"

  subnet_id       = "subnet-xxx"
  subnet_cidr     = "10.1.0.0/24"
  security_groups = ["sg-xxx"]

  license_type = "byol"

}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.fad](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.ni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_ami_ids.fad_amis_byol](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids) | data source |
| [aws_ami_ids.fad_amis_payg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.fad_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | fad username used for API key | `string` | `"admin"` | no |
| <a name="input_cidr_host"></a> [cidr\_host](#input\_cidr\_host) | First IP number of the network to assign | `number` | `10` | no |
| <a name="input_config_eip"></a> [config\_eip](#input\_config\_eip) | Boolean to enable/disable EIP configuration | `bool` | `true` | no |
| <a name="input_fad_btw"></a> [fad\_btw](#input\_fad\_btw) | FAD Bandwith 100mbps, 200mbps, 500mbps ... | `string` | `"100mbps"` | no |
| <a name="input_fad_extra_config"></a> [fad\_extra\_config](#input\_fad\_extra\_config) | Extra config to add to bootstrap user-data | `string` | `""` | no |
| <a name="input_fad_version"></a> [fad\_version](#input\_fad\_version) | FAD version | `string` | `"7.2.0"` | no |
| <a name="input_iam_profile"></a> [iam\_profile](#input\_iam\_profile) | IAM profile to assing to the instance | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | FortiAnalyzer instance type | `string` | `"c4.xlarge"` | no |
| <a name="input_keypair"></a> [keypair](#input\_keypair) | AWS key pair name | `string` | `null` | no |
| <a name="input_license_file"></a> [license\_file](#input\_license\_file) | License file path | `string` | `"./licenses/licenseFAD.lic"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License Type to create FortiGate-VM | `string` | `"payg"` | no |
| <a name="input_ni_id"></a> [ni\_id](#input\_ni\_id) | Network Interface ID used if provided | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP used to create Network Interface | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_rsa-public-key"></a> [rsa-public-key](#input\_rsa-public-key) | SSH RSA public key for KeyPair | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security groups to assign to NI | `list(string)` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of the subnet, use to assign NI private IP | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID, necessary if ni\_id it is not provided to create NI | `string` | `null` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br/>  "project": "terraform"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_details"></a> [details](#output\_details) | FortiADC details |
| <a name="output_id"></a> [id](#output\_id) | FortiADC instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | FortiADC private IP |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | FortiADC public IP |
<!-- END_TF_DOCS -->

## Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.