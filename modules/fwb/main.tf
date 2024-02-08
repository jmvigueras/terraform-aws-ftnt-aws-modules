#-----------------------------------------------------------------------------------------------------
# fac
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
resource "aws_instance" "fwb" {
  ami           = var.license_type == "byol" ? data.aws_ami_ids.fwb_amis_byol.ids[0] : data.aws_ami_ids.fwb_amis_payg.ids[0]
  instance_type = var.instance_type
  key_name      = var.keypair
  //iam_instance_profile = null
  //user_data = data.template_file.fwb_config.rendered

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
    { Name = "${var.prefix}-fwb" },
    var.tags
  )
}

data "template_file" "fwb_config" {
  template = file("${path.module}/templates/fwb.conf")
  vars = {
    fwb_id           = "${var.prefix}-fwb"
    type             = var.license_type
    license_file     = var.license_file
    admin_username   = var.admin_username
    rsa-public-key   = var.rsa-public-key != null ? trimspace(var.rsa-public-key) : ""
    fwb_extra-config = var.fwb_extra_config
  }
}