variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "terraform"
}

variable "tags" {
  description = "Tags for created resources"
  type        = map(any)
  default = {
    project = "terraform"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs that NLB will use"
  type    = list(string)
  default = null
}

variable "vpc_id" {
  description = "VPC ID where targets are deployed"
  type    = string
  default = null
}

variable "gwlb_service_name" {
  description = "GWLB service name"
  type    = string
  default = null
}

