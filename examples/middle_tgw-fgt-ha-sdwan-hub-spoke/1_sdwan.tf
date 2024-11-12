#------------------------------------------------------------------------------
# Create FGT cluster EU
# - VPC
# - FGT NI and SG
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "sdwan_vpc" {
  source   = "../../modules/vpc"
  for_each = local.sdwan_spokes

  prefix     = "${local.prefix}-${each.value["id"]}"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.spoke_azs

  cidr = each.value["cidr"]

  public_subnet_names  = local.sdwan_public_subnet_names
  private_subnet_names = local.sdwan_private_subnet_names
}
# Create FGT NIs
module "sdwan_nis" {
  source   = "../../modules/fgt_ni_sg"
  for_each = local.sdwan_spokes

  prefix             = "${local.prefix}-${each.value["id"]}"
  azs                = local.spoke_azs
  vpc_id             = module.sdwan_vpc[each.key].vpc_id
  subnet_list        = module.sdwan_vpc[each.key].subnet_list
  fgt_subnet_tags    = local.sdwan_subnet_tags
  fgt_number_peer_az = local.fgt_number_peer_az
}
# Create FGT config peer each FGT
module "sdwan_config" {
  source   = "../../modules/fgt_config"
  for_each = { for i, v in local.sdwan_config : "${v["sdwan_id"]}.${v["fgt_id"]}" => v }

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = module.sdwan_nis[each.value["sdwan_id"]].fgt_ports_config[each.value["fgt_id"]]
  fgt_id       = each.value["fgt_id"]
  ha_members   = module.sdwan_nis[each.value["sdwan_id"]].fgt_ports_config

  config_spoke = true
  spoke        = local.sdwan_spokes[each.value["sdwan_id"]]
  hubs         = local.hubs

  static_route_cidrs = [local.sdwan_spokes[each.value["sdwan_id"]]["cidr"]]
}
# Create FGT
module "sdwan" {
  source   = "../../modules/fgt"
  for_each = local.sdwan_spokes

  prefix        = "${local.prefix}-${each.value["id"]}"
  region        = local.region
  instance_type = local.instance_type
  keypair       = aws_key_pair.keypair.key_name

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.sdwan_nis[each.key].fgt_ni_list
  fgt_config  = { for i, v in local.sdwan_config : v["fgt_id"] => module.sdwan_config["${v["sdwan_id"]}.${v["fgt_id"]}"].fgt_config if tostring(v["sdwan_id"]) == each.key }
}
# Create route to <local.hub_cidr> in bastion subnets RT to FortiGate private NI
module "sdwan_vpc_routes" {
  source   = "../../modules/vpc_routes"
  for_each = local.sdwan_spokes


  ni_id     = module.sdwan_nis[each.key].fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.sdwan_ni_rt_ids[each.key]

  destination_cidr_block = local.hub_cidr
}
# Crate test VM in bastion subnet
module "sdwan_vm" {
  source   = "../../modules/vm"
  for_each = local.sdwan_spokes

  prefix          = "${local.prefix}-${each.value["id"]}"
  keypair         = trimspace(aws_key_pair.keypair.key_name)
  subnet_id       = module.sdwan_vpc[each.key].subnet_ids["az1"]["bastion"]
  subnet_cidr     = module.sdwan_vpc[each.key].subnet_cidrs["az1"]["bastion"]
  security_groups = [module.sdwan_vpc[each.key].sg_ids["default"]]
}