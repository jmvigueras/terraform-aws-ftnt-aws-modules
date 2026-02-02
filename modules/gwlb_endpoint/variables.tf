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
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where targets are deployed"
  type        = string
}

variable "gwlb_service_name" {
  description = "GWLB service name"
  type        = string
}

variable "ip_address_type" {
  description = "IP address type for the GWLB endpoints"
  type        = string
  validation {
    condition     = contains(["ipv4", "ipv6", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be either 'ipv4', 'ipv6', or 'dualstack'."
  }
  default = "ipv4"
}