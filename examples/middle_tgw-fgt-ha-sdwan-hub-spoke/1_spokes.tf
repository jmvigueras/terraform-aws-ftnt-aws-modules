#------------------------------------------------------------------------------
# Create FGT cluster EU
# - VPC
# - FGT NI and SG
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "spoke_vpc" {
  source   = "../../modules/vpc"
  for_each = local.vpc_spokes

  prefix     = "${var.prefix}-${each.value["id"]}"
  admin_cidr = var.admin_cidr
  region     = var.region
  azs        = local.spoke_azs

  cidr = each.value["cidr"]

  public_subnet_names  = local.spoke_public_subnet_names
  private_subnet_names = local.spoke_private_subnet_names
}
# Create TGW attachment
module "spoke_vpc_tgw_attachment" {
  source   = "../../modules/tgw_attachment"
  for_each = local.vpc_spokes

  prefix = "${var.prefix}-${each.value["id"]}"

  vpc_id             = module.spoke_vpc[each.key].vpc_id
  tgw_id             = module.tgw.tgw_id
  tgw_subnet_ids     = compact([for i, az in local.spoke_azs : lookup(module.spoke_vpc[each.key].subnet_ids["az${i + 1}"], "tgw", "")])
  rt_association_id  = module.tgw.rt_pre_inspection_id
  rt_propagation_ids = [module.tgw.rt_post_inspection_id]

  appliance_mode_support = "disable"
}
# Create route to <local.hub_cidr> in VM subnets RT to TGW
module "spoke_vpc_routes" {
  source   = "../../modules/vpc_routes"
  for_each = local.vpc_spokes

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.vpc_spoke_ni_rt_ids[each.key]

  destination_cidr_block = local.hub[0]["cidr"]
}

# Crate test VM in bastion subnet
module "spoke_vm" {
  source   = "../../modules/vm"
  for_each = { for i, v in local.vpc_spokes : i => v }

  prefix          = "${var.prefix}-${each.value["id"]}"
  keypair         = trimspace(aws_key_pair.keypair.key_name)
  subnet_id       = module.spoke_vpc[each.key].subnet_ids["az1"]["vm"]
  subnet_cidr     = module.spoke_vpc[each.key].subnet_cidrs["az1"]["vm"]
  security_groups = [module.spoke_vpc[each.key].sg_ids["default"]]
}