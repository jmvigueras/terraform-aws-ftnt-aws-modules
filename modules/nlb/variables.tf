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

variable "fgt_ips" {
  description = "List of IPs of Fortigates used as NLB target groups"
  type    = list(string)
  default = null
}

variable "listeners" {
  description = "Map of ports and protocol to create NLB listeners (pattern: port = protocol)"
  type    = map(string)
  default = {
    "500"  = "UPD"
    "4500" = "UDP"
    "80"   = "TCP"
    "443"  = "TCP"
  }
}

variable "backend_port" {
  description = "Fortigates backend port used for health checks probes"
  type    = string
  default = "8008"
}

variable "backend_protocol" {
  description = "Fortigates backend protocol used for health checks probes"
  type    = string
  default = "HTTP"
}

variable "backend_interval" {
  description = "Health checks probes interval in seconds"
  type    = number
  default = 10
}