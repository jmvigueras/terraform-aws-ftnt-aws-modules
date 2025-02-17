#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "hub_mgmt" {
  value = {
    fgt1_mgmt   = "https://${one(module.hub_nis.fgt_ni_list["az1.fgt1"]["mgmt_eips"])}:${var.admin_port}"
    fgt2_mgmt   = "https://${one(module.hub_nis.fgt_ni_list["az2.fgt1"]["mgmt_eips"])}:${var.admin_port}"
    fgt_user    = "admin"
    fgt_pwd     = element(module.hub.fgt_list, 0).id
    fgt1_public = one(module.hub_nis.fgt_ni_list["az1.fgt1"]["public_eips"])
  }
}

output "sdwan_mgmt" {
  value = { for k, v in module.sdwan :
    "sdwan${k + 1}" =>
    {
      fgt1_mgmt   = "https://${one(module.sdwan_nis[k].fgt_ni_list["az1.fgt1"]["public_eips"])}:${var.admin_port}"
      fgt_user    = "admin"
      fgt_pwd     = element(module.sdwan[k].fgt_list, 0).id
      fgt1_public = one(module.sdwan_nis[k].fgt_ni_list["az1.fgt1"]["public_eips"])
    }
  }
}

output "sdwan_vms" {
  value = { for k, v in module.sdwan_vm :
    "vm-sdwan${k + 1}" =>
    {
      public_ip  = module.sdwan_vm[k].vm["public_ip"]
      private_ip = module.sdwan_vm[k].vm["private_ip"]
    }
  }
}

output "spoke_vms" {
  value = { for k, v in module.spoke_vm :
    "vm-spoke${k + 1}" =>
    {
      public_ip  = module.spoke_vm[k].vm["public_ip"]
      private_ip = module.spoke_vm[k].vm["private_ip"]
    }
  }
}

/*
#-------------------------------
# Debugging 
#-------------------------------
*/