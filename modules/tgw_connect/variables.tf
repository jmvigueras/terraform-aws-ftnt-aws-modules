variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "terraform"
}

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type        = string
  default     = null
}

variable "peers" {
  description = "List of map with Fortigate instance IPs and id"
  type        = list(map(string))
  default = [
    { "inside_cidr" = "169.254.101.0/29",
      "tgw_ip"      = "172.20.10.10",
      "id"          = "az1.fgt1",
      "fgt_ip"      = "172.20.0.10",
      "fgt_bgp_asn" = "65000"
    }
  ]
}

variable "max_connect_attachment" {
  description = "Maximum TGW connect attachment over a VPC attachment"
  type        = number
  default     = 3
}

variable "tgw_id" {
  description = "AWS TGW ID"
  type        = string
  default     = null
}

variable "vpc_attachment_id" {
  description = "AWS VPC attachment ID"
  type        = string
  default     = null
}

variable "rt_association_id" {
  description = "AWS TGW Route Table ID to associate the new VPC attachment"
  type        = string
  default     = null
}

variable "rt_propagation_ids" {
  description = "AWS TGW Route Table IDs where new attachment VPC CIDR will be propagated"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    owner   = "terraform"
    project = "terraform-deploy"
  }
}