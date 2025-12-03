#--------------------------------------------------------------------------------------------------------------
# Custom variable example
#--------------------------------------------------------------------------------------------------------------
variable "custom_vars" {
  description = "Custom variables"
  default = {
    prefix                     = "fgt-vpc-sec"
    region                     = "eu-west-1"
    azs                        = ["eu-west-1a", "eu-west-1b"]
    fgt_number_peer_az         = 1
    fgt_build                  = "build2795"
    license_type               = "byol"
    fgt_size                   = "c6i.xlarge"
    fgt_cluster_type           = "fgcp"
    fgt_vpc_cidr               = "172.10.0.0/24"
    public_subnet_names_extra  = []
    private_subnet_names_extra = ["tgw"]
    config_mgmt_nat_gateway   = false
    config_mgmt_private       = false
    config_gwlb               = false
    tags                       = { 
      "Deploy" = "Fortigate PRO", 
      "Project" = "Fortigate Produccion 2AZ"
    }
  }
}

#--------------------------------------------------------------------------------------------------------------
# FGT VPC Security deployment
#--------------------------------------------------------------------------------------------------------------
module "fgt" {
  source  = "../../modules/fgt_sec_vpc"
 
  prefix = var.custom_vars["prefix"]
 
  region = var.custom_vars["region"]
  azs    = var.custom_vars["azs"]
 
  fgt_build     = var.custom_vars["fgt_build"]
  license_type  = var.custom_vars["license_type"]
  instance_type = var.custom_vars["fgt_size"]
 
  fgt_number_peer_az = var.custom_vars["fgt_number_peer_az"]
  fgt_cluster_type   = var.custom_vars["fgt_cluster_type"]
  config_gwlb        = var.custom_vars["config_gwlb"]
 
  fgt_vpc_cidr               = var.custom_vars["fgt_vpc_cidr"]
  public_subnet_names_extra  = var.custom_vars["public_subnet_names_extra"]
  private_subnet_names_extra = var.custom_vars["private_subnet_names_extra"]
 
  config_mgmt_nat_gateway = var.custom_vars["config_mgmt_nat_gateway"]
  config_mgmt_private     = var.custom_vars["config_mgmt_private"]
}

#-------------------------------
# Outputs 
#-------------------------------
output "fgt" {
  value = module.fgt.fgt
}

output "fgt_api_key" {
  value = module.fgt.api_key
}