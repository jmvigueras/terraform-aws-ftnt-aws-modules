#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  # map tags used in fgt_subnet_tags to tag subnet names (this valued are define in modules as default)
  subnet_tags = var.subnet_tags != null ? var.subnet_tags : {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha"
  }

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  #      - leave blank or don't add elements to not create a ports
  #      - FGCP type of cluster requires a management port
  #      - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file.
  fgt_subnet_tags = var.fgt_subnet_tags != null ? var.fgt_subnet_tags : {
    "port1.${local.subnet_tags["public"]}"  = "untrusted"
    "port2.${local.subnet_tags["private"]}" = "trusted"
    "port3.${local.subnet_tags["mgmt"]}"    = var.fgt_cluster_type == "fgcp" ? "mgmt" : ""
    "port4.${local.subnet_tags["ha"]}"      = ""
  }

  # List of subnet names for FortiGate public and private subnets
  fgt_public_subnets = [
    local.fgt_subnet_tags["port1.${local.subnet_tags["public"]}"],
    var.config_mgmt_private ? "" : local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"]
  ]
  fgt_private_subnets = [
    local.fgt_subnet_tags["port2.${local.subnet_tags["private"]}"],
    local.fgt_subnet_tags["port4.${local.subnet_tags["ha"]}"],
    var.config_mgmt_private ? local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"] : ""
  ]

  # List of subnet names in FortiGate VPC
  public_subnet_names  = concat(local.fgt_public_subnets, var.public_subnet_names_extra)
  private_subnet_names = var.config_gwlb ? concat(local.fgt_private_subnets, var.private_subnet_names_extra, ["gwlb"]) : concat(local.fgt_private_subnets, var.private_subnet_names_extra)

  # FortiGate API key
  fgt_api_key = var.fgt_api_key != null ? var.fgt_api_key : random_string.api_key.result

  # GWLB endpoints ips (control locals values if var.config_gwlb is false to avoid functions errors)
  gwlbe_ips_list = try(values(module.gwlb[0].gwlbe_ips), [])
  gwlbe_ips_map  = try(zipmap(keys(module.fgt_nis.fgt_ports_config), local.gwlbe_ips_list), {})

  # Fortiflex token map
  fortiflex_token_map = {
    for i, k in keys(try(module.fgt_nis.fgt_ports_config, {})) :
    k => try(var.fortiflex_tokens[i], "")
  }

  # NAT Gateway map (deploy one peer AZ)
  nat_gw_subnet_map = {
    for i, v in var.azs : "az${i + 1}" => {
      subnet_id = lookup(module.fgt_vpc.subnet_ids["az${i + 1}"], local.fgt_subnet_tags["port1.${local.subnet_tags["public"]}"], ""),
      rt_id     = lookup(module.fgt_vpc.rt_ids["az${i + 1}"], local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"], "")
    } if var.config_mgmt_nat_gateway
  }
}
