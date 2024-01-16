# Terraform Module: Amazon Network Load Balancer

Create an Amazon Network Load Balancer and target group.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"
  region      = "eu-west-1"
  azs         = ["eu-west-1a","eu-west-1b"]
  admin_cidr  = "0.0.0.0/0"

  public_subnet_names  = ["public", "mgmt", "bastion"]
  private_subnet_names = ["private", "tgw"]
}

module "example" {
  source            = "github.com/your-organization/your-module-8"
  prefix            = "terraform"
  tags              = {
    project = "terraform"
  }
  subnet_ids        = null
  vpc_id            = null
  fgt_ips           = null
  listeners         = {
    "500"  = "UDP"
    "4500" = "UDP"
    "80"   = "TCP"
    "443"  = "TCP"
  }
  backend_port      = "8008"
  backend_protocol  = "HTTP"
  backend_interval  = 10
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
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.nlb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.nlb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.nlb_tg_fgt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_interval"></a> [backend\_interval](#input\_backend\_interval) | Health checks probes interval in seconds | `number` | `10` | no |
| <a name="input_backend_port"></a> [backend\_port](#input\_backend\_port) | Fortigates backend port used for health checks probes | `string` | `"8008"` | no |
| <a name="input_backend_protocol"></a> [backend\_protocol](#input\_backend\_protocol) | Fortigates backend protocol used for health checks probes | `string` | `"HTTP"` | no |
| <a name="input_fgt_ips"></a> [fgt\_ips](#input\_fgt\_ips) | List of IPs of Fortigates used as NLB target groups | `list(string)` | `null` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | Map of ports and protocol to create NLB listeners (pattern: port = protocol) | `map(string)` | <pre>{<br>  "443": "TCP",<br>  "4500": "UDP",<br>  "500": "UPD",<br>  "80": "TCP"<br>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs that NLB will use | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where targets are deployed | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gwlb_service_name"></a> [gwlb\_service\_name](#output\_gwlb\_service\_name) | Service name of the GWLB VPC endpoint |
| <a name="output_gwlbe_ids"></a> [gwlbe\_ids](#output\_gwlbe\_ids) | List of GWLB Endpoint Network Interface IDs |
| <a name="output_gwlbe_ips"></a> [gwlbe\_ips](#output\_gwlbe\_ips) | List of GWLB Endpoint private IPs |
| <a name="output_lb_target_group_arn"></a> [lb\_target\_group\_arn](#output\_lb\_target\_group\_arn) | ARN of the LB Target Group |
| <a name="output_lb_target_group_id"></a> [lb\_target\_group\_id](#output\_lb\_target\_group\_id) | ID of the LB Target Group |
<!-- END_TF_DOCS -->