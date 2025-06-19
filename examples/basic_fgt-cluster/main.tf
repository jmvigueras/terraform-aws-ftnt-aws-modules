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

  prefix     = var.prefix
  admin_cidr = var.admin_cidr
  region     = var.region
  azs        = var.azs

  cidr = var.fgt_vpc_cidr

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names

  tags = var.tags
}
# Create FGT NIs
module "fgt_nis" {
  source = "../../modules/fgt_ni_sg"

  prefix = var.prefix
  azs    = var.azs

  vpc_id      = module.fgt_vpc.vpc_id
  subnet_list = module.fgt_vpc.subnet_list

  subnet_tags     = local.subnet_tags
  fgt_subnet_tags = local.fgt_subnet_tags

  fgt_number_peer_az = var.fgt_number_peer_az
  cluster_type       = var.fgt_cluster_type

  tags = var.tags
}
# Create FGTs config
module "fgt_config" {
  source = "../../modules/fgt_config"

  for_each = { for k, v in module.fgt_nis.fgt_ports_config : k => v }

  admin_cidr     = var.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = local.fgt_api_key

  ports_config = each.value

  config_fgcp       = var.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = var.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = var.fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.fgt_nis.fgt_ports_config

  config_gwlb           = var.config_gwlb
  gwlbe_ip              = lookup(local.gwlbe_ips_map, each.key, "")
  gwlb_inspection_cidrs = var.inspection_vpc_cidrs

  static_route_cidrs = [var.fgt_vpc_cidr] //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "fgt" {
  source = "../../modules/fgt"

  prefix        = var.prefix
  region        = var.region
  instance_type = var.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = var.license_type
  fgt_build    = var.fgt_build

  fgt_ni_list = module.fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.fgt_config : k => v.fgt_config }

  tags = var.tags
}
# Create GWLB
module "gwlb" {
  source = "../../modules/gwlb"

  count = var.config_gwlb ? 1 : 0

  prefix     = var.prefix
  subnet_ids = { for k, v in module.fgt_vpc.subnet_ids : k => lookup(v, "gwlb", "") }
  vpc_id     = module.fgt_vpc.vpc_id
  fgt_ips    = compact([for k, v in module.fgt_nis.fgt_ips_map : lookup(v, "port2.${local.subnet_tags["private"]}", "")])

  backend_port     = "8008"
  backend_protocol = "HTTP"
  backend_interval = 10

  tags = var.tags
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
  key_name   = "${var.prefix}-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${var.prefix}-ssh-key.pem"
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