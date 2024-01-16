variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "terraform"
}

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type    = string
  default = null
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    owner   = "terraform"
    project = "terraform-deploy"
  }
}

variable "tgw_bgp_asn" {
  description = "Amazon side TGW BGP"
  type    = string
  default = "64515"
}

variable "tgw_cidr" {
  description = "Amazon side TGW CIDR"
  type    = string
  default = "172.29.10.0/24"
}
