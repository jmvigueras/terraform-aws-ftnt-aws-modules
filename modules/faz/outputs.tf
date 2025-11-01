output "faz" {
  description = "FortiAnalyzer details"
  value = {
    faz_id     = aws_instance.faz.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiAnalyzer instance ID"
  value       = aws_instance.faz.id
}

output "private_ip" {
  description = "FortiAnalyzer private IP"
  value       = local.private_ip
}

output "public_ip" {
  description = "FortiAnalyzer public IP"
  value       = local.public_ip
}