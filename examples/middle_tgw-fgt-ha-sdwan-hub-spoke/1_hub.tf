#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FGT NI and SG
# - Fortigate config
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "hub_vpc" {
  source = "../../modules/vpc"

  prefix     = "${var.prefix}-hub"
  admin_cidr = var.admin_cidr
  region     = var.region
  azs        = local.hub_azs

  cidr = local.hub[0]["vpc_cidr"]

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
}
# Create FGT NIs
module "hub_nis" {
  source = "../../modules/fgt_ni_sg"

  prefix = "${var.prefix}-hub"
  azs    = local.hub_azs

  vpc_id      = module.hub_vpc.vpc_id
  subnet_list = module.hub_vpc.subnet_list

  subnet_tags     = local.subnet_tags
  fgt_subnet_tags = local.hub_subnet_tags

  fgt_number_peer_az = local.fgt_number_peer_az
  cluster_type       = local.fgt_cluster_type
}
# Create FGTs config
module "hub_config" {
  for_each = { for k, v in module.hub_nis.fgt_ports_config : k => v }
  source   = "../../modules/fgt_config"

  admin_cidr     = var.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.hub_nis.fgt_ports_config

  config_hub = true
  hub        = local.hub

  static_route_cidrs = [local.hub[0]["vpc_cidr"]] //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "hub" {
  source = "../../modules/fgt"

  prefix        = "${var.prefix}-hub"
  region        = var.region
  instance_type = local.hub[0]["instance_type"]
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.hub[0]["license_type"]
  fgt_build    = local.hub[0]["fgt_build"]

  fgt_ni_list = module.hub_nis.fgt_ni_list
  fgt_config  = { for k, v in module.hub_config : k => v.fgt_config }
}
# Create TGW
module "tgw" {
  source = "../../modules/tgw"

  prefix = var.prefix

  tgw_cidr    = var.tgw["cidr"]
  tgw_bgp_asn = var.tgw["bgp_asn"]
}
# Create TGW Attachment
module "tgw_attachment" {
  source = "../../modules/tgw_attachment"

  prefix = var.prefix

  vpc_id         = module.hub_vpc.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [module.hub_vpc.subnet_ids["az1"]["tgw"]]

  default_rt_association = true
  appliance_mode_support = "enable"

  tags = var.tags
}
#------------------------------------------------------------------------------
# Update VPC routes
#------------------------------------------------------------------------------
# Create route to <local.hub_cidr> in TGW endpoint and bastion subnets RT to FortiGate master private NI
module "ns_tgw_vpc_routes_to_fgt_ni" {
  source = "../../modules/vpc_routes"

  ni_id     = module.hub_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.hub_ni_rt_ids

  destination_cidr_block = local.hub[0]["cidr"]
}

# Create route to 0.0.0.0/0 at FortiGates private subnet RT to TGW
module "ns_fgt_private_routes_to_tgw" {
  source = "../../modules/vpc_routes"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.hub_tgw_rt_ids
}
