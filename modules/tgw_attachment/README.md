# Terraform Module: AWS TGW VPC attachment

Create a VPC TGW attachment.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix = "module-tgw-attach"
  azs    = ["eu-west-1a", "eu-west-1c"]

  tags        = {
    owner   = "Fortinet"
    project = "Terraform module TGW"
  }
  
  tgw_subnet_ids = compact([for i, az in local.azs : lookup(module.vpc.subnet_ids["az${i + 1}"], "tgw", "")])
}

module "example" {
  source = "../tgw_attachment"

  prefix = local.prefix

  vpc_id             = module.vpc.vpc_id
  tgw_id             = module.tgw.tgw_id
  tgw_subnet_ids     = local.tgw_subnet_ids
  rt_association_id  = module.tgw.rt_post_inspection_id
  rt_propagation_ids = [module.tgw.rt_default_id, module.tgw.rt_pre_inspection_id]

  appliance_mode_support = "enable"

  tags = local.tags
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
| [aws_ec2_transit_gateway_route_table_association.rt_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.rt_propagation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appliance_mode_support"></a> [appliance\_mode\_support](#input\_appliance\_mode\_support) | Attachment mode used for NVA | `string` | `"enable"` | no |
| <a name="input_default_rt_association"></a> [default\_rt\_association](#input\_default\_rt\_association) | Enable TGW default route table association | `bool` | `false` | no |
| <a name="input_default_rt_propagation"></a> [default\_rt\_propagation](#input\_default\_rt\_propagation) | Enable TGW default route table association | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_rt_association_id"></a> [rt\_association\_id](#input\_rt\_association\_id) | AWS TGW Route Table ID to associate the new VPC attachment | `string` | `null` | no |
| <a name="input_rt_propagation_ids"></a> [rt\_propagation\_ids](#input\_rt\_propagation\_ids) | AWS TGW Route Table IDs where new attachment VPC CIDR will be propagated | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Attribute for tag Enviroment | `map(any)` | <pre>{<br>  "owner": "terraform",<br>  "project": "terraform-deploy"<br>}</pre> | no |
| <a name="input_tgw_id"></a> [tgw\_id](#input\_tgw\_id) | AWS TGW ID to attach | `string` | `null` | no |
| <a name="input_tgw_subnet_ids"></a> [tgw\_subnet\_ids](#input\_tgw\_subnet\_ids) | Subnet IDs used by TGW in VPC | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to attach | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the AWS Transit Gateway VPC Attachment |
<!-- END_TF_DOCS -->