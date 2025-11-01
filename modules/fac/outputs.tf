output "details" {
  description = "FortiAuthenticator details"
  value = {
    id         = aws_instance.fac.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiAuthenticator instance ID"
  value       = aws_instance.fac.id
}

output "private_ip" {
  description = "FortiAuthenticator private IP"
  value       = local.private_ip
}

output "public_ip" {
  description = "FortiAuthenticator public IP"
  value       = local.public_ip
}