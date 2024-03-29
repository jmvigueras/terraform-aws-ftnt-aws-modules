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

  prefix     = "${local.prefix}-inspection"
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

  prefix = "${local.prefix}-fgsp"
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
  source   = "../../modules/fgt_config"
  for_each = { for k, v in module.fgt_nis.fgt_ports_config : k => v }

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

  config_gwlb           = true
  gwlbe_ip              = lookup(zipmap(keys(module.fgt_nis.fgt_ports_config), values(module.gwlb.gwlbe_ips)), each.key, "")
  gwlb_inspection_cidrs = [local.vpc_services_cidr]

  static_route_cidrs = [local.fgt_vpc_cidr] //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "fgt" {
  source = "../../modules/fgt"

  prefix        = "${local.prefix}-fgsp"
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.fgt_config : k => v.fgt_config }
}
# Create GWLB
module "gwlb" {
  source = "../../modules/gwlb"

  prefix     = local.prefix
  subnet_ids = { for k, v in module.fgt_vpc.subnet_ids : k => lookup(v, "gwlb", "") }
  vpc_id     = module.fgt_vpc.vpc_id
  fgt_ips    = compact([for k, v in module.fgt_nis.fgt_ips_map : lookup(v, "port2.${local.subnet_tags["private"]}", "")])

  backend_port     = "8008"
  backend_protocol = "HTTP"
  backend_interval = 10

  tags = local.tags
}
# Create GWLB endpoints
# - use key as servers subnet names to use in module vpc_routes to identify servers subnets route tables
module "gwlb_endpoint" {
  source = "../../modules/gwlb_endpoint"

  gwlb_service_name = module.gwlb.gwlb_service_name
  subnet_ids        = { for i, v in local.azs : "servers-az${i + 1}" => lookup(module.vpc_services.subnet_ids["az${i + 1}"], "gwlbe", "") }
  vpc_id            = module.vpc_services.vpc_id

  tags = local.tags
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
# Get your public IP
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}