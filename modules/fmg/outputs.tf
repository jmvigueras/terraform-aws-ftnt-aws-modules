output "fmg" {
  description = "FortiManager details"
  value = {
    fmg_id     = aws_instance.fmg.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiManager instance ID"
  value       = aws_instance.fmg.id
}

output "private_ip" {
  description = "FortiManager private IP"
  value       = local.private_ip
}

output "public_ip" {
  description = "FortiManager public IP"
  value       = local.public_ip
}