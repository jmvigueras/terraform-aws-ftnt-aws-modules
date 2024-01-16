# Terraform Module: AWS Transit Gateway

Create AWS Transit Gateway with two preconfigure route tables.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix  = "module-tgw"

  tags = {
    owner   = "Fortinet"
    project = "Terraform module TGW"
  }
}

module "example" {
  source      = "../tgw"

  prefix      = local.prefix
  tags        = localtags

  tgw_bgp_asn = "64515"
  tgw_cidr    = "172.29.10.0/24"
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route_table.rt_post_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.rt_pre_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Attribute for tag Enviroment | `map(any)` | <pre>{<br>  "owner": "terraform",<br>  "project": "terraform-deploy"<br>}</pre> | no |
| <a name="input_tgw_bgp_asn"></a> [tgw\_bgp\_asn](#input\_tgw\_bgp\_asn) | Amazon side TGW BGP | `string` | `"64515"` | no |
| <a name="input_tgw_cidr"></a> [tgw\_cidr](#input\_tgw\_cidr) | Amazon side TGW CIDR | `string` | `"172.29.10.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rt_default_id"></a> [rt\_default\_id](#output\_rt\_default\_id) | ID of the association default route table |
| <a name="output_rt_post_inspection_id"></a> [rt\_post\_inspection\_id](#output\_rt\_post\_inspection\_id) | ID of the route table post-inspection |
| <a name="output_rt_pre_inspection_id"></a> [rt\_pre\_inspection\_id](#output\_rt\_pre\_inspection\_id) | ID of the route table pre-inspection |
| <a name="output_tgw_id"></a> [tgw\_id](#output\_tgw\_id) | ID of the transit gateway |
| <a name="output_tgw_owner_id"></a> [tgw\_owner\_id](#output\_tgw\_owner\_id) | Owner ID of the transit gateway |
<!-- END_TF_DOCS -->