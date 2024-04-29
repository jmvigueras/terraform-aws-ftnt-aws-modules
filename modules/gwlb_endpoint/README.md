# Terraform Module: Gateway Load Balancer endpoints

Create a Amazon Gateway Load Balancer endpoints

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
module "example" {
  source            = "../"
  prefix            = "gwlb-module"
  tags              = {
    project = "terraform"
  }
  subnet_ids          = {
    "gwlb-az1" = "subnet-xxx", 
    "gwlb-az2" = "subnet-xxx"
  }
  vpc_id              = "vpc-xxx"
  gwlb_service_name   = "com.amazonaws.vpce.eu-xxx"
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
| [aws_vpc_endpoint.gwlb_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gwlb_service_name"></a> [gwlb\_service\_name](#input\_gwlb\_service\_name) | GWLB service name | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs that NLB will use | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where targets are deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gwlb_endpoints"></a> [gwlb\_endpoints](#output\_gwlb\_endpoints) | Map of IDs of GWLB endpoint created |
<!-- END_TF_DOCS -->