#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fad_ids" {
  value = [for k, v in module.fad : v.id]
}

output "fad_public_ips" {
  value = [for k, v in module.fad : v.public_ip]
}

output "fad_private_ips" {
  value = [for k, v in module.fad : v.private_ip]
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