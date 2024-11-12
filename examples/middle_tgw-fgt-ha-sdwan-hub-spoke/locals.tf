locals {
  ## Generate locals needed at modules ##

  #-----------------------------------------------------------------------------------------------------
  # VPC details
  #-----------------------------------------------------------------------------------------------------
  fgt_number_peer_az = 1
  fgt_cluster_type   = "fgcp" // choose type of cluster either fgsp or fgcp  

  # fgt_tags -> map tags used in hub_subnet_tags to tag subnet names (this valued are define in modules as default)
  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha-sync"
  }

  # hub_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - leave blank or don't add elements to not create a ports
  # - FGCP type of cluster requires a management port
  # - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. 
  hub_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "untrusted"
    "port2.${local.subnet_tags["private"]}" = "trusted"
    "port3.${local.subnet_tags["mgmt"]}"    = "mgmt"
    "port4.${local.subnet_tags["ha"]}"      = ""
  }

  sdwan_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "untrusted"
    "port2.${local.subnet_tags["private"]}" = "trusted"
    "port3.${local.subnet_tags["mgmt"]}"    = ""
    "port4.${local.subnet_tags["ha"]}"      = ""
  }

  # VPC - list of public and private subnet names
  public_subnet_names  = [local.hub_subnet_tags["port1.public"], local.hub_subnet_tags["port3.mgmt"], "bastion"]
  private_subnet_names = [local.hub_subnet_tags["port2.private"], local.hub_subnet_tags["port4.ha-sync"], "tgw"]

  sdwan_public_subnet_names  = [local.sdwan_subnet_tags["port1.public"], local.sdwan_subnet_tags["port3.mgmt"], "bastion"]
  sdwan_private_subnet_names = [local.sdwan_subnet_tags["port2.private"], local.sdwan_subnet_tags["port4.ha-sync"]]

  spoke_public_subnet_names  = ["vm"]
  spoke_private_subnet_names = ["tgw"]

  #-----------------------------------------------------------------------------------------------------
  # HUB
  #-----------------------------------------------------------------------------------------------------
  # Config VPN DialUps FGT HUB
  hub = [
    {
      id                = local.hub_id
      bgp_asn_hub       = local.hub_bgp_asn
      bgp_asn_spoke     = local.hub_id
      vpn_cidr          = local.hub_vpn_cidr
      vpn_psk           = trimspace(random_string.vpn_psk.result)
      cidr              = local.hub_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
      local_gw          = ""
    }
  ]

  # List of subnet names to add a route to FGT NI
  hub_ni_rt_subnet_names = ["bastion", "tgw"]
  # List of subnet names to add a route to a TGW
  hub_tgw_rt_subnet_names = [local.hub_subnet_tags["port2.private"]]

  # Create map of RT IDs where add routes pointing to a FGT NI
  hub_ni_rt_ids = {
    for pair in setproduct(local.hub_ni_rt_subnet_names, [for i, az in local.hub_azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  hub_tgw_rt_ids = {
    for pair in setproduct(local.hub_tgw_rt_subnet_names, [for i, az in local.hub_azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Map of public IPs of EU HUB
  hub_public_eips = module.hub_nis.fgt_eips_map

  #-----------------------------------------------------------------------------------------------------
  # SDWAN SPOKE to HUB
  #-----------------------------------------------------------------------------------------------------
  # HUBs variables
  hub_public_ip  = module.hub_nis.fgt_eips_map["az1.fgt1.port1.public"]
  hub_private_ip = ""

  # Define SDWAN HUB EMEA CLOUD
  hubs = [for hub in local.hub :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_ip       = hub["vpn_port"] == "public" ? local.hub_public_ip : local.hub_private_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 0), 3)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]

  # List of subnet names to add a route to FGT NI
  sdwan_ni_rt_subnet_names = ["bastion"]

  # Create map of RT IDs where add routes pointing to a TGW ID
  sdwan_ni_rt_ids = [
    for i in range(0, local.sdwan_spoke_number) : {
      for pair in setproduct(local.sdwan_ni_rt_subnet_names, [for i, az in local.spoke_azs : "az${i + 1}"]) :
      "${pair[0]}-${pair[1]}" => module.sdwan_vpc["${i}"].rt_ids[pair[1]][pair[0]]
    }
  ]
  # Create FGTs config (auxiliary local list)
  sdwan_config = flatten([
    for i in range(0, local.sdwan_spoke_number) :
    [for ii, v in local.spoke_azs :
      { "sdwan_id" = "${i}"
        "fgt_id"   = "az${ii + 1}.fgt${ii + 1}"
      }
    ]
    ]
  )

  #-----------------------------------------------------------------------------------------------------
  # SPOKE to TGW
  #-----------------------------------------------------------------------------------------------------
  # Create map of RT IDs where add routes pointing to a TGW ID
  vpc_spoke_ni_rt_ids = [
    for i in range(0, local.vpc_spoke_number) : {
      for pair in setproduct(local.spoke_public_subnet_names, [for i, az in local.spoke_azs : "az${i + 1}"]) :
      "${pair[0]}-${pair[1]}" => module.spoke_vpc["${i}"].rt_ids[pair[1]][pair[0]]
    }
  ]
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
