locals {
  rfc1918_cidrs = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  default       = "0.0.0.0/0"

  ni_rt_ids           = var.ni_rt_ids 
  tgw_rt_ids          = var.tgw_rt_ids 
  gwlb_rt_ids         = var.gwlb_rt_ids
  core_network_rt_ids = var.core_network_rt_ids
}