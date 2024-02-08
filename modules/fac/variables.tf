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
  type        = string
  default     = null
}

variable "instance_type" {
  description = "FortiAnalyzer instance type"
  type        = string
  default     = "c4.xlarge"
}

variable "subnet_id" {
  description = "Subnet ID, necessary if ni_id it is not provided to create NI"
  type        = string
  default     = null
}

variable "subnet_cidr" {
  description = "CIDR of the subnet, use to assign NI private IP"
  type        = string
  default     = null
}

variable "config_eip" {
  description = "Boolean to enable/disable EIP configuration"
  type        = bool
  default     = true
}

variable "cidr_host" {
  description = "First IP number of the network to assign"
  type        = number
  default     = 10
}

variable "security_groups" {
  description = "List of security groups to assign to NI"
  type        = list(string)
  default     = null
}

variable "keypair" {
  description = "AWS key pair name"
  type        = string
  default     = null
}

variable "iam_profile" {
  description = "IAM profile to assing to the instance"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "fac username used for API key"
  type        = string
  default     = "admin"
}

variable "fac_extra_config" {
  description = "Extra config to add to bootstrap user-data"
  type        = string
  default     = ""
}

variable "fac_version" {
  description = "FAC version"
  type        = string
  default     = "6.2.1"
}

variable "fac_ami_id" {
  description = "Map of AMI IDs peer region, version 6.2.1"
  type        = map(string)
  default = {
    "eu-west-1"    = "ami-025cad1c66ca4834a" // Ireland
    "eu-west-2"    = "ami-037e725edf43ddd8e" // London
    "eu-west-3"    = "ami-0c31451a94fa4787b" // Paris
    "eu-south-1"   = "ami-09f8df2e0da94a587" // Milan
    "eu-south-2"   = "ami-0a7c47f369c1cf374" // Spain
    "eu-central-1" = "ami-0783e89cad5ef71f9" // Frankfurt
    "eu-north-1"   = "ami-0909de6351735a4da" // Stockholm
  }
}

variable "rsa-public-key" {
  description = "SSH RSA public key for KeyPair"
  type        = string
  default     = null
}

variable "license_type" {
  description = "License Type to create FortiGate-VM"
  type        = string
  default     = "payg"
}

variable "license_file" {
  description = "License file path"
  type        = string
  default     = "./licenses/licenseFAC.lic"
}