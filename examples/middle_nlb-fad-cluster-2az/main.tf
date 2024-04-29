#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FAC instances
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "fad_vpc" {
  source = "../../modules/vpc"

  prefix     = "${local.prefix}-fad"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fad_vpc_cidr

  public_subnet_names  = local.fad_public_subnet_names
  private_subnet_names = local.fad_private_subnet_names
}
# Create FAC VM
module "fad" {
  source = "../../modules/fad"

  for_each = { for i, pair in setproduct([for i, k in local.azs : "az${i + 1}"], range(0, local.fad_number_peer_az)) : "${pair[0]}.fac${pair[1]}" => pair[0] }

  prefix  = local.prefix
  keypair = aws_key_pair.keypair.key_name

  subnet_id       = module.fad_vpc.subnet_ids[each.value]["vm"]
  subnet_cidr     = module.fad_vpc.subnet_cidrs[each.value]["vm"]
  security_groups = [module.fad_vpc.sg_ids["default"]]

  fad_btw       = local.fad_btw
  instance_type = local.fad_instance_type
  license_type  = local.fad_license_type
}
# Create NLB
module "nlb" {
  source = "../../modules/nlb"

  prefix     = local.prefix
  subnet_ids = [for i, k in module.fad_vpc.subnet_ids : k["vm"]]
  vpc_id     = module.fad_vpc.vpc_id
  fgt_ips    = [for k, v in module.fad : v.private_ip]

  listeners = {
    "80"  = "TCP"
    "443" = "TCP"
  }

  backend_port     = "443"
  backend_protocol = "TCP"
  backend_interval = 10
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