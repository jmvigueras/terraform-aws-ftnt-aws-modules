output "details" {
  description = "FortiMail details"
  value = {
    id         = aws_instance.fmail.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiMail instance ID"
  value       = aws_instance.fmail.id
}

output "private_ip" {
  description = "FortiMail private IP"
  value       = local.private_ip
}

output "public_ip" {
  description = "FortiMail public IP"
  value       = local.public_ip
}

# Debbuging
output "ami_names" {
  value  = {
    payg = "FortiMail-VMAW-64*${var.fmail_version}*PAYG*"
    byol = "FortiMail-VMAW-64*${var.fmail_version}*BYOL*"
 }
}