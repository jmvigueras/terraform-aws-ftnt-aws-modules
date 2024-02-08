#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fwb_ids" {
  value = [for k, v in module.fwb : v.id]
}

output "fwb_public_ips" {
  value = [for k, v in module.fwb : v.public_ip]
}

output "fwb_private_ips" {
  value = [for k, v in module.fwb : v.private_ip]
}

output "nlb" {
  value = module.nlb.nlb_ips
}

/*
#-------------------------------
# Debugging 
#-------------------------------
output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}

output "fgt_ni_ports_config" {
  value = module.fgt_nis.fgt_ports_config
}

output "ni_list" {
  value = module.fgt_nis.ni_list
}
*/