#--------------------------------------------------------------------------------------------------------------
# Custom variable example
#--------------------------------------------------------------------------------------------------------------
variable "custom_vars" {
  description = "Custom variables"
  type = object({
    prefix                     = optional(string, "fgt-vpc-sec")
    region                     = optional(string, "eu-west-1")
    number_azs                 = optional(number, 2)
    fgt_number_peer_az         = optional(number, 1)
    fgt_build                  = optional(string, "build3651")
    license_type               = optional(string, "payg")
    fortiflex_tokens           = optional(list(string), [])
    fgt_size                   = optional(string, "c6i.xlarge")
    fgt_cluster_type           = optional(string, "fgcp")
    fgt_vpc_cidr               = optional(string, "172.10.0.0/24")
    public_subnet_names_extra  = optional(list(string), [])
    private_subnet_names_extra = optional(list(string), ["tgw"])
    config_mgmt_nat_gateway    = optional(bool, false)
    config_mgmt_private        = optional(bool, false)
    config_gwlb                = optional(bool, false)
    tags = optional(map(string), {
      "Deploy"  = "Fortigate Security VPC"
      "Project" = "Fortigate Terraform AWS Modules"
    })
  })
  default = {}
}

#--------------------------------------------------------------------------------------------------------------
# FGT VPC Security deployment
#--------------------------------------------------------------------------------------------------------------
module "fgt" {
  source = "../../modules/fgt_sec_vpc"

  prefix = var.custom_vars["prefix"]

  region = var.custom_vars["region"]
  azs    = local.azs

  fgt_build        = var.custom_vars["fgt_build"]
  license_type     = var.custom_vars["license_type"]
  fortiflex_tokens = var.custom_vars["fortiflex_tokens"]
  instance_type    = var.custom_vars["fgt_size"]

  fgt_number_peer_az = var.custom_vars["fgt_number_peer_az"]
  fgt_cluster_type   = var.custom_vars["fgt_cluster_type"]

  fgt_vpc_cidr               = var.custom_vars["fgt_vpc_cidr"]
  public_subnet_names_extra  = var.custom_vars["public_subnet_names_extra"]
  private_subnet_names_extra = var.custom_vars["private_subnet_names_extra"]

  config_mgmt_nat_gateway = var.custom_vars["config_mgmt_nat_gateway"]
  config_mgmt_private     = var.custom_vars["config_mgmt_private"]

  config_gwlb = var.custom_vars["config_gwlb"]

  tags = var.custom_vars["tags"]
}

#-------------------------------------------------------------------------------------------------------------
# Outputs 
#-------------------------------------------------------------------------------------------------------------
output "fgt" {
  value = module.fgt.fgt
}

output "fgt_api_key" {
  value = module.fgt.api_key
}

#-------------------------------------------------------------------------------------------------------------
# Data and Locals
#-------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.custom_vars["number_azs"])
}