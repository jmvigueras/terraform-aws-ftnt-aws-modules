#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix to add to AWS resources names"
  type        = string
  default     = "fgt-sdwan"
}

variable "tags" {
  description = "Map of tags to add to AWS resources"
  type        = map(string)
  default = {
    Project = "ftnt_modules_aws"
  }
}

variable "admin_cidr" {
  description = "Admin CIDR to limit access to FortiGates and test VMs"
  type        = string
  default     = "0.0.0.0/0"
}

variable "admin_port" {
  description = "Admin port to configure at FortiGates"
  type        = string
  default     = "8443"
}

variable "default_bgp_asn" {
  description = "Default BGP"
  type        = string
  default     = "65000"
}

variable "default_fgt_build" {
  description = "Default FortiGate version if not defined by input variable"
  type        = string
  default     = "build2795"
}

variable "default_license_type" {
  description = "Default FortiGate consume service model"
  type        = string
  default     = "payg"
}

variable "default_fgt_instance" {
  description = "Default FortiGate instance type"
  type        = string
  default     = "c6i.large"
}

variable "tgw" {
  description = "TGW data"
  type        = map(string)
  default = {
    cidr    = "10.1.10.0/24"
    bgp_asn = "65010"
  }
}

variable "hub" {
  description = "Details to deploy SDWAN HUB"
  type        = map(string)
  default = {
    id            = "hub"
    vpc_cidr      = "10.1.0.0/24"
    bgp_network   = "10.0.0.0/8"      // BGP advertised and routed to FGT HUB within AWS
    vpn_cidr      = "172.16.100.0/24" // VPN DialUp spokes cidr
    instance_type = "c6i.large"       //(optional if not defined use default variable value <var.default_fgt_instance>)
    fgt_build     = "build2702"       //(optional if not defined use default variable value <var.default_fgt_build>)
    license_type  = "payg"            //(optional if not defined use default variable value <var.default_license_type>)
    bgp_asn       = "65000"           //(optional if not defined use default variable value <var.default_license_type>)
  }
}

variable "spoke_sdwan" {
  description = "Details to deploy SDWAN SPOKES"
  type        = list(map(string))
  default = [
    {
      id            = "sdwan1"
      vpc_cidr      = "10.1.101.0/24"
      instance_type = "c6i.large" //(optional if not defined use default variable value <var.default_fgt_instance>)
      fgt_build     = "build2702" //(optional if not defined use default variable value <var.default_fgt_build>)
      license_type  = "payg"      //(optional if not defined use default variable value <var.default_license_type>)
      bgp_asn       = "65000"     //(optional if not defined use default variable value <var.default_license_type>)    
    },
    {
      id            = "sdwan2"
      vpc_cidr      = "10.1.102.0/24"
      instance_type = "c6i.large" //(optional if not defined use default variable value <var.default_fgt_instance>)
      fgt_build     = "build2702" //(optional if not defined use default variable value <var.default_fgt_build>)
      license_type  = "payg"      //(optional if not defined use default variable value <var.default_license_type>)
      bgp_asn       = "65000"     //(optional if not defined use default variable value <var.default_license_type>)    
    }
  ]
}

variable "spoke_vpc" {
  description = "Details to deploy SPOKES VPC to TGW"
  type        = list(map(string))
  default = [
    {
      id       = "vpc1"
      vpc_cidr = "10.1.201.0/24"
    },
    {
      id       = "vpc2"
      vpc_cidr = "10.1.202.0/24"
    }
  ]
}


