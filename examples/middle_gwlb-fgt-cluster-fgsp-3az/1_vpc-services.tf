#------------------------------------------------------------------------------
# Create Services VPC
# - VPC
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "vpc_services" {
  source = "../../modules/vpc"

  prefix     = "${local.prefix}-services"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.vpc_services_cidr

  public_subnet_names  = local.vpc_services_public_subnet_names
  private_subnet_names = local.vpc_services_private_subnet_names
}
# Update private RT route RFC1918 cidrs to GWLBe
module "vpc_services_routes" {
  source   = "../../modules/vpc_routes"
  for_each = module.gwlb_endpoint.gwlb_endpoints

  gwlbe_id    = each.value
  gwlb_rt_ids = { "${each.key}" = lookup(module.vpc_services.rt_public_ids, each.key, "") }
}