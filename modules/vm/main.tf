#-----------------------------------------------------------------------------------------------------
# VM LINUX for testing
#-----------------------------------------------------------------------------------------------------
locals {
  # Locals for generate resources
  ni_id      = var.ni_id != null ? var.ni_id : one(aws_network_interface.ni.*.id)
  private_ip = var.private_ip != null ? var.private_ip : cidrhost(var.subnet_cidr, var.cidr_host)
  # Outputs
  public_ip = var.config_eip ? one(aws_eip.eip.*.public_ip) : ""
}

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
# Create Amazon Linux EC2 Instance
resource "aws_instance" "vm" {
  count         = var.iam_profile != null ? 0 : 1
  ami           = var.linux_os == "ubuntu" ? data.aws_ami.ami_ubuntu.id : data.aws_ami.ami_amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.keypair
  user_data     = var.user_data == null ? file("${path.module}/templates/${var.linux_os}_user-data.sh") : var.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.disk_size
    volume_type           = var.disk_type
    delete_on_termination = true
    encrypted             = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = local.ni_id
  }

  tags = merge(
    { Name = "${var.prefix}-vm-${var.suffix}" },
    var.tags
  )
}
# Create Amazon Linux EC2 Instance
resource "aws_instance" "vm_iam_profile" {
  count                = var.iam_profile != null ? 1 : 0
  ami                  = var.linux_os == "ubuntu" ? data.aws_ami.ami_ubuntu.id : data.aws_ami.ami_amazon_linux_2.id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_profile
  key_name             = var.keypair
  user_data            = var.user_data == null ? file("${path.module}/templates/${var.linux_os}_user-data.sh") : var.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.disk_size
    volume_type           = var.disk_type
    delete_on_termination = true
    encrypted             = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = local.ni_id
  }

  tags = merge(
    { Name  = "${var.prefix}-vm-${var.suffix}" },
    var.tags
  )
}

// Retrieve AMI info
data "aws_ami" "ami_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// Amazon Linux 2 AMI
data "aws_ami" "ami_amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}



