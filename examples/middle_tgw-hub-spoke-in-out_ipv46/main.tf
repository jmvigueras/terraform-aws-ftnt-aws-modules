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
    fgt_build                  = optional(string, "build3652")
    license_type               = optional(string, "payg")
    fortiflex_tokens           = optional(list(string), [])
    fgt_size                   = optional(string, "c6i.xlarge")
    fgt_cluster_type           = optional(string, "fgcp")
    fgt_vpc_cidr               = optional(string, "172.16.0.0/24")
    public_subnet_names_extra  = optional(list(string), [])
    private_subnet_names_extra = optional(list(string), ["tgw", "dmz"])
    config_mgmt_nat_gateway    = optional(bool, false)
    config_mgmt_private        = optional(bool, false)
    config_gwlb                = optional(bool, false)
    tgw_cidr                   = optional(string, "172.16.10.0/24")
    tgw_bgp_asn                = optional(number, 65000)
    spoke_vpc_cidr             = optional(string, "172.16.20.0/24")
    tags = optional(map(string), {
      "Deploy"  = "Fortigate Security VPC"
      "Project" = "Fortigate Terraform AWS Modules"
    })
  })
  default = {}
}

#--------------------------------------------------------------------------------------------------------------
# FGT VPC HUB 
#--------------------------------------------------------------------------------------------------------------
module "fgt" {
  source = "../../modules/fgt_sec_vpc_ipv46"

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

# Create DMZ VM
module "dmz_vm" {
  source = "../../modules/vm"

  prefix          = "${var.custom_vars["prefix"]}-dmz"
  keypair         = module.fgt.keypair_name
  subnet_id       = module.fgt.subnet_ids["az1"]["dmz"]
  subnet_cidr     = module.fgt.subnet_cidrs["az1"]["dmz"]
  security_groups = [module.fgt.sg_ids["default"]]
}

#--------------------------------------------------------------------------------------------------------------
# Spoke VPC 
#--------------------------------------------------------------------------------------------------------------
module "spoke_vpc" {
  source = "../../modules/vpc_ipv46"

  prefix = "${var.custom_vars["prefix"]}-spoke"

  region = var.custom_vars["region"]
  azs    = local.azs

  cidr = var.custom_vars["spoke_vpc_cidr"]

  public_subnet_names  = []
  private_subnet_names = ["tgw", "vms"]
}
# Crate spoke VM
module "spoke_vm" {
  source = "../../modules/vm"

  prefix          = "${var.custom_vars["prefix"]}-spoke"
  keypair         = module.fgt.keypair_name
  subnet_id       = module.spoke_vpc.subnet_ids["az1"]["vms"]
  subnet_cidr     = module.spoke_vpc.subnet_cidrs["az1"]["vms"]
  security_groups = [module.spoke_vpc.sg_ids["default"]]
}

#--------------------------------------------------------------------------------------------------------------
# TGW
#--------------------------------------------------------------------------------------------------------------
# Create TGW
module "tgw" {
  source = "../../modules/tgw"

  prefix = var.custom_vars["prefix"]

  tgw_cidr    = var.custom_vars["tgw_cidr"]
  tgw_bgp_asn = var.custom_vars["tgw_bgp_asn"]
}
# Create TGW Attachments
module "fgt_vpc_tgw_attachment" {
  source = "../../modules/tgw_attachment"

  prefix = "${var.custom_vars["prefix"]}-fgt"

  vpc_id         = module.fgt.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [module.fgt.subnet_ids["az1"]["tgw"]]

  rt_association_id  = module.tgw.rt_post_inspection_id
  rt_propagation_ids = [module.tgw.rt_pre_inspection_id]

  appliance_mode_support = "enable"
  ipv6_support           = "enable"

  tags = var.custom_vars["tags"]
}
module "spoke_vpc_tgw_attachment" {
  source = "../../modules/tgw_attachment"

  prefix = "${var.custom_vars["prefix"]}-spoke"

  vpc_id         = module.spoke_vpc.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [module.spoke_vpc.subnet_ids["az1"]["tgw"]]

  rt_association_id  = module.tgw.rt_pre_inspection_id
  rt_propagation_ids = [module.tgw.rt_post_inspection_id, module.tgw.rt_default_id]

  appliance_mode_support = "disable"
  ipv6_support           = "enable"

  tags = var.custom_vars["tags"]
}

#--------------------------------------------------------------------------------------------------------------
# Routes
#--------------------------------------------------------------------------------------------------------------
# Create TGW routes to this FGT VPC attachment
resource "aws_ec2_transit_gateway_route" "pre_inspection_routes_to_fgt_ipv4" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.fgt_vpc_tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.rt_pre_inspection_id
}
resource "aws_ec2_transit_gateway_route" "pre_inspection_routes_to_fgt_ipv6" {
  destination_cidr_block         = "::/0"
  transit_gateway_attachment_id  = module.fgt_vpc_tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.rt_pre_inspection_id
}
# Create subnet routes to point to FGT trusted NI
module "tgw_private_routes_to_fgt" {
  source = "../../modules/vpc_routes_ipv46"

  ni_id     = module.fgt.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.ni_rt_ids
}
# Create routes to point to TGW
module "fgt_private_routes_to_tgw" {
  source = "../../modules/vpc_routes_ipv46"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.fgt_tgw_rt_ids
}
module "spoke_private_routes_to_tgw" {
  source = "../../modules/vpc_routes_ipv46"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.spoke_tgw_rt_ids
}

# Variables to create maps of route tables to create subnet routes
locals {
  # Create map of RT IDs where add routes pointing to a FGT NI
  ni_rt_ids = {
    for pair in setproduct(["tgw", "dmz"], [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  fgt_tgw_rt_ids = {
    for pair in setproduct(["trusted"], [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt.rt_ids[pair[1]][pair[0]]
  }
  spoke_tgw_rt_ids = {
    for pair in setproduct(["vms"], [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.spoke_vpc.rt_ids[pair[1]][pair[0]]
  }
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

resource "local_file" "ssh_private_key_pem" {
  content         = module.fgt.ssh_private_key_pem
  filename        = "./ssh-key/${var.custom_vars["prefix"]}-ssh-key.pem"
  file_permission = "0600"
}

#-------------------------------------------------------------------------------------------------------------
# Debugging Outputs
#-------------------------------------------------------------------------------------------------------------
output "debug_vpc_subnet_cidrs" {
  value = module.fgt.subnet_cidrs
}
output "debug_vpc_rt_ids" {
  value = module.fgt.rt_ids
}
