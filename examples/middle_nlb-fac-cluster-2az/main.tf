#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FAC instances
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "fac_vpc" {
  source = "../../modules/vpc"

  prefix     = "${local.prefix}-fac"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fgt_vpc_cidr

  public_subnet_names  = local.fac_public_subnet_names
  private_subnet_names = local.fac_private_subnet_names
}
# Create FAC VM
module "fac" {
  source = "../../modules/fac"

  for_each = { for i, pair in setproduct([for i, k in local.azs : "az${i + 1}"], range(0,local.fac_number_peer_az)) : "${pair[0]}.fac${pair[1]}" => pair[0] }

  prefix          = "${local.prefix}"
  keypair         = aws_key_pair.keypair.key_name
  instance_type   = local.fac_instance_type
  
  subnet_id       = module.fac_vpc.subnet_ids[each.value]["vm"]
  subnet_cidr     = module.fac_vpc.subnet_cidrs[each.value]["vm"]
  security_groups = [module.fac_vpc.sg_ids["default"]]

  license_type = "byol"
}
# Create NLB
module "nlb" {
  source            = "../../modules/nlb"

  prefix            = "${local.prefix}"
  subnet_ids        = [ for i, k in module.fac_vpc.subnet_ids : k["vm"]]
  vpc_id            = module.fac_vpc.vpc_id
  fgt_ips           = [ for k, v in module.fac : v.private_ip ]

  listeners         = {
    "80"   = "TCP"
    "443"  = "TCP"
  }

  backend_port      = "443"
  backend_protocol  = "TCP"
  backend_interval  = 10
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