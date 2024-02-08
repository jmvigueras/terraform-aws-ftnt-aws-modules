#-----------------------------------------------------------------------------------------------------
# FAZ
#-----------------------------------------------------------------------------------------------------
# Create Network interface
# Create EIP public NI
# - Creeat EIP associated to NI if config_eip is true
resource "aws_eip" "eip" {
  depends_on = [resource.aws_network_interface.ni]
  count      = var.config_eip ? 1 : 0

  domain            = "vpc"
  network_interface = local.ni_id

  tags = merge(
    { Name = "${var.prefix}-vm-eip-ni-${var.suffix}" },
    var.tags
  )
}
# Create NIs based on NI list
resource "aws_network_interface" "ni" {
  count = var.ni_id == null ? 1 : 0

  subnet_id       = var.subnet_id
  security_groups = var.security_groups
  private_ips     = [local.private_ip]

  tags = merge(
    { Name = "${var.prefix}-vm-ni-${var.suffix}" },
    var.tags
  )
}

# Create the instance FGT AZ1 Active
resource "aws_instance" "faz" {
  ami               = var.license_type == "byol" ? data.aws_ami_ids.faz_amis_byol.ids[0] : data.aws_ami_ids.faz_amis_payg.ids[0]
  instance_type     = var.instance_type
  key_name          = var.keypair
  //iam_instance_profile = null
  user_data         = data.template_file.faz_config.rendered

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = local.ni_id
  }

  tags = merge(
    { Name = "${var.prefix}-faz" },
    var.tags
  )
}

data "template_file" "faz_config" {
  template = file("${path.module}/templates/faz.conf")
  vars = {
    faz_id           = "${var.prefix}-faz"
    type             = var.license_type
    license_file     = var.license_file
    admin_username   = var.admin_username
    rsa-public-key   = trimspace(var.rsa-public-key)
    faz_extra-config = var.faz_extra_config
  }
}

# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "faz_amis_payg" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiAnalyzer-VM64-AWSONDEMAND ${var.faz_build}*"]
  }
}

data "aws_ami_ids" "faz_amis_byol" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiAnalyzer-VM64-AWS ${var.faz_build}*"]
  }
}