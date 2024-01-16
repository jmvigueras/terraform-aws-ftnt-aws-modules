# Terraform Module: new instance

Create new EC2 instance.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"
}

module "example" {
  source = "../vm"

  prefix          = "${local.prefix}-spoke"
  keypair         = aws_key_pair.eu_keypair.key_name
  subnet_id       = "subnet-xxx"
  subnet_cidr     = "10.1.0.0/24"
  security_groups = ["sg-xxx"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.vm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.vm_iam_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.ni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_ami.ami_amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.ami_ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_host"></a> [cidr\_host](#input\_cidr\_host) | First IP number of the network to assign | `number` | `10` | no |
| <a name="input_config_eip"></a> [config\_eip](#input\_config\_eip) | Boolean to enable/disable EIP configuration | `bool` | `true` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Volumen size of root volumen of Linux Server | `number` | `10` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Volumen type of root volumen of Linux Server. | `string` | `"gp2"` | no |
| <a name="input_iam_profile"></a> [iam\_profile](#input\_iam\_profile) | n/a | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Server instance type | `string` | `"t3.micro"` | no |
| <a name="input_keypair"></a> [keypair](#input\_keypair) | n/a | `string` | `null` | no |
| <a name="input_linux_os"></a> [linux\_os](#input\_linux\_os) | n/a | `string` | `"ubuntu"` | no |
| <a name="input_ni_id"></a> [ni\_id](#input\_ni\_id) | Network Interface ID used if provided | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP used to create Network Interface | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security groups to assign to NI | `list(string)` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of the subnet, use to assign NI private IP | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID, necessary if ni\_id it is not provided to create NI | `string` | `null` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud-init script | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm"></a> [vm](#output\_vm) | Map with details of deployed vm |
<!-- END_TF_DOCS -->