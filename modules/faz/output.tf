output "faz" {
  description = "FortiAnalyzer details"
  value = {
    faz_id     = aws_instance.faz.id
    username   = var.admin_username
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}