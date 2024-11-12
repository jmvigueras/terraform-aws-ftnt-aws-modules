#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FGT NI and SG
# - Fortigate config
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "fgt_vpc" {
  source = "../../modules/vpc"

  prefix     = "${local.prefix}-fgcp"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fgt_vpc_cidr

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
}
# Create FGT NIs
module "fgt_nis" {
  source = "../../modules/fgt_ni_sg"

  prefix = "${local.prefix}-fgcp"
  azs    = local.azs

  vpc_id      = module.fgt_vpc.vpc_id
  subnet_list = module.fgt_vpc.subnet_list

  subnet_tags     = local.subnet_tags
  fgt_subnet_tags = local.fgt_subnet_tags

  fgt_number_peer_az = local.fgt_number_peer_az
  cluster_type       = local.fgt_cluster_type
}
# Create FGTs config
module "fgt_config" {
  for_each = { for k, v in module.fgt_nis.fgt_ports_config : k => v }
  source   = "../../modules/fgt_config"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.fgt_nis.fgt_ports_config

  bgp_asn_default = local.fgt_bgp_asn

  config_tgw_gre = true
  tgw_gre_peer = {
    tgw_ip        = one([for i, v in local.tgw_peers : v["tgw_ip"] if v["id"] == each.key])
    inside_cidr   = one([for i, v in local.tgw_peers : v["inside_cidr"] if v["id"] == each.key])
    tgw_bgp_asn   = local.tgw_bgp_asn
    route_map_out = ""
    route_map_in  = ""
    gre_name      = "gre-to-tgw"
  }

  static_route_cidrs = [local.fgt_vpc_cidr, local.tgw_cidr] //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "fgt" {
  source = "../../modules/fgt"

  prefix        = "${local.prefix}-fgcp"
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.fgt_config : k => v.fgt_config }
}
# Create TGW
module "tgw" {
  source = "../../modules/tgw"

  prefix = local.prefix

  tgw_cidr    = local.tgw_cidr
  tgw_bgp_asn = local.tgw_bgp_asn
}
# Create TGW Attachment
module "tgw_attachment" {
  source = "../../modules/tgw_attachment"

  prefix = local.prefix

  vpc_id         = module.fgt_vpc.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [module.fgt_vpc.subnet_ids["az1"]["tgw"]]

  default_rt_association = true
  appliance_mode_support = "enable"

  tags = local.tags
}
# Create TGW attachment connect
locals {
  tgw_peers = [
    { "inside_cidr" = "169.254.101.0/29",
      "tgw_ip"      = cidrhost(local.tgw_cidr, 10),
      "id"          = "az1.fgt1",
      "fgt_ip"      = module.fgt_nis.fgt_ips_map["az1.fgt1"]["port2.private"],
      "fgt_bgp_asn" = local.fgt_bgp_asn
    },
    { "inside_cidr" = "169.254.102.0/29",
      "tgw_ip"      = cidrhost(local.tgw_cidr, 11),
      "id"          = "az2.fgt1",
      "fgt_ip"      = module.fgt_nis.fgt_ips_map["az2.fgt1"]["port2.private"],
      "fgt_bgp_asn" = local.fgt_bgp_asn
    }
  ]
}
module "tgw_attachment_connect" {
  source = "../../modules/tgw_connect"

  prefix = local.prefix

  vpc_attachment_id = module.tgw_attachment.id
  tgw_id            = module.tgw.tgw_id

  rt_association_id  = module.tgw.rt_post_inspection_id
  rt_propagation_ids = [module.tgw.rt_pre_inspection_id]

  peers = local.tgw_peers

  tags = local.tags
}



#------------------------------------------------------------------------------
# Update VPC routes
#------------------------------------------------------------------------------
# Create TGW endpoint subnet RT 0.0.0.0/0 to point to Fortigate private NI
module "ns_tgw_vpc_routes_to_fgt_ni" {
  source = "../../modules/vpc_routes"

  ni_id     = module.fgt_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.ni_rt_ids
}
# Create Fortigate private subnet RT 0.0.0.0/0 to point to TGW
module "ns_fgt_private_routes_to_tgw" {
  source = "../../modules/vpc_routes"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.tgw_rt_ids
}
# Variables to create maps of route tables to create subnet routes
locals {
  ni_rt_subnet_names    = ["tgw"]
  tgw_rt_subnet_private = [local.fgt_subnet_tags["port2.private"]]
  # Create map of RT IDs where add routes pointing to a FGT NI
  ni_rt_ids = {
    for pair in setproduct(local.ni_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  tgw_rt_ids = {
    for pair in setproduct(local.tgw_rt_subnet_private, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
}

#------------------------------------------------------------------------------
# General resources
#------------------------------------------------------------------------------
# Create key-pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "keypair" {
  key_name   = "${local.prefix}-eu-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 20
  special = false
  numeric = true
}
/*
# Get your public IP
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
*/