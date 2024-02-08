output "details" {
  description = "FortiWEB details"
  value = {
    id         = aws_instance.fwb.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiWEB instance ID"
  value       = aws_instance.fwb.id
}

output "private_ip" {
  description = "FortiWEB private IP"
  value       = local.private_ip
}

output "public_ip" {
  description = "FortiWEB public IP"
  value       = local.public_ip
}