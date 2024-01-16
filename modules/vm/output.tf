output "vm" {
  description = "Map with details of deployed vm"
  value = {
    vm_id      = var.iam_profile == null ? aws_instance.vm.*.id[0] : aws_instance.vm_iam_profile.*.id[0]
    adminuser  = var.linux_os == "ubuntu" ? "ubuntu" : "ec2-user"
    private_ip = local.private_ip
    public_ip  = local.public_ip
  }
}