#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt" {
  value = { for i, v in module.fgt.fgt_list :
    v["fgt"] => {
      fgt_pass = v["id"]
      fgt_mgmt = "https://${element(lookup(module.fgt_nis.fgt_ni_list, v["fgt"], "").mgmt_eips, 0)}:${var.admin_port}"
    }
  }
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