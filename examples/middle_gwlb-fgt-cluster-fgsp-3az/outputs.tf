#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt_ids" {
  value = module.fgt.fgt_list
}

output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}

/*
#-------------------------------
# Debugging 
#-------------------------------
output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}

output "ni_list" {
  value = module.fgt_nis.ni_list
}

output "fgt_ni_ports_config" {
  value = module.fgt_nis.fgt_ports_config
}

output "fgt_vpc_subnets_ids" {
  value = module.fgt_vpc.subnet_ids
}

output "vpc_services_rt_ids" {
  value = module.vpc_services.rt_private_ids
}

output "gwlbe_subnets_ids" {
  value = { for i, v in local.azs : "servers-az${i + 1}" => lookup(module.vpc_services.subnet_ids["az${i + 1}"], "gwlbe", "") }
}

output "gwlb_endpoint" {
  value = module.gwlb_endpoint
}
*/