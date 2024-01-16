variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "terraform"
}

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type    = string
  default = null
}

variable "tgw_id" {
  description = "AWS TGW ID to attach"
  type    = string
  default = null
}

variable "vpc_id" {
  description = "VPC ID to attach"
  type    = string
  default = null
}

variable "tgw_subnet_ids" {
  description = "Subnet IDs used by TGW in VPC"
  type    = list(string)
  default = null
}

variable "rt_association_id" {
  description = "AWS TGW Route Table ID to associate the new VPC attachment"
  type    = string
  default = null
}

variable "rt_propagation_ids" {
  description = "AWS TGW Route Table IDs where new attachment VPC CIDR will be propagated"
  type    = list(string)
  default = []
}

variable "default_rt_association" {
  description = "Enable TGW default route table association "
  type    = bool
  default = false
}

variable "default_rt_propagation" {
  description = "Enable TGW default route table association "
  type    = bool
  default = false
}

variable "appliance_mode_support" {
  description = "Attachment mode used for NVA"
  type    = string
  default = "enable"
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    owner   = "terraform"
    project = "terraform-deploy"
  }
}