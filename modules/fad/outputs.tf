output "details" {
  description = "FortiADC details"
  value = {
    id         = aws_instance.fad.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiADC instance ID"
  value       = aws_instance.fad.id
}

output "private_ip" {
  description = "FortiADC private IP"
  value       = local.private_ip
}

output "public_ip" {
  description = "FortiADC public IP"
  value       = local.public_ip
}