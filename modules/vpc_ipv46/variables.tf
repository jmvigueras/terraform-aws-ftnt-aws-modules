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

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type        = string
  default     = null
}

variable "azs" {
  description = "Availability zones where Fortigates will be deployed"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1c"]
}

variable "admin_cidr" {
  description = "CIDR for the administrative access to Fortigates"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "172.20.0.0/23"
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
  default     = ["public", "bastion"]
}

variable "private_subnet_names" {
  description = "Names for private subnets"
  type        = list(string)
  default     = ["private", "tgw"]
}

# Enable IPv6 for dual-stack (default: false)
variable "enable_ipv6" {
  description = "Enable IPv6 dual-stack for VPC and subnets. If true, assigns an AWS global IPv6 CIDR block unless 'ipv6_cidr_block' is provided."
  type        = bool
  default     = true
}

# Optional: Provide a custom IPv6 CIDR block (rare, for BYOIPv6). If not set, AWS assigns a global IPv6 block automatically.
variable "ipv6_cidr_block" {
  description = "Optional: IPv6 CIDR block for the VPC. If not set and enable_ipv6 is true, AWS assigns a global IPv6 CIDR block automatically."
  type        = string
  default     = null
}