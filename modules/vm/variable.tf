variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "terraform"
}

variable "suffix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "1"
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

variable "ni_id" {
  description = "Network Interface ID used if provided"
  type        = string
  default     = null
}

variable "private_ip" {
  description = "Private IP used to create Network Interface"
  type    = string
  default = null
}

variable "instance_type" {
  description = "Server instance type"
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID, necessary if ni_id it is not provided to create NI"
  type    = string
  default = null
}

variable "subnet_cidr" {
  description = "CIDR of the subnet, use to assign NI private IP"
  type    = string
  default = null
}

variable "config_eip" {
  description = "Boolean to enable/disable EIP configuration"
  type    = bool
  default = true
}

variable "cidr_host" {
  description = "First IP number of the network to assign"
  type        = number
  default     = 10
}

variable "security_groups" {
  description = "List of security groups to assign to NI"
  type    = list(string)
  default = null
}

variable "keypair" {
  type    = string
  default = null
}

variable "disk_size" {
  type        = number
  description = "Volumen size of root volumen of Linux Server"
  default     = 10
}

variable "disk_type" {
  type        = string
  description = "Volumen type of root volumen of Linux Server."
  default     = "gp2"
}

variable "user_data" {
  type        = string
  description = "Cloud-init script"
  default     = null
}

variable "iam_profile" {
  type    = string
  default = null
}

variable "linux_os" {
  type    = string
  default = "ubuntu"
}