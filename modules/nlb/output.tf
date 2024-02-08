# Output
output "lb_target_group_arn" {
  description = "ARN of the LB Target Group"
  value       = aws_lb_target_group.nlb_target_group.arn
}
output "lb_target_group_id" {
  description = "ID of the LB Target Group"
  value       = aws_lb_target_group.nlb_target_group.id
}
output "nlb_ips" {
  description = "List of NLB Interfaces private IPs"
  value       = [for k, v in data.aws_network_interface.nlb_ni : v.private_ip]
}