#---------------------------------------------------------------------------
# NLB
# - Create nlb
# - Create Endpoint Service
# - Create Target Group
# - Create Listener 
# - Attach Fortigate IPs to target group
#---------------------------------------------------------------------------
// Create Network LB
resource "aws_lb" "nlb" {
  load_balancer_type               = "network"
  name                             = "${var.prefix}-nlb"
  enable_cross_zone_load_balancing = false
  subnets                          = var.subnet_ids

  tags = merge(
    {Name = "${var.prefix}-nlb"},
    var.tags
  )
}
// Create Gateway LB target group 
resource "aws_lb_target_group" "nlb_target_group" {
  name        = "${var.prefix}-nlb-tg"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    port     = var.backend_port
    protocol = var.backend_protocol
    interval = var.backend_interval
  }
}
// Create nlb target group attachemnt to FGT
resource "aws_lb_target_group_attachment" "nlb_tg_fgt" {
  for_each = {for idx, ip in var.fgt_ips : idx => ip} // map of FGT IPs with value FGT IP

  target_group_arn = aws_lb_target_group.nlb_target_group.arn
  target_id        = each.value
}
// Create NLB listeners
resource "aws_lb_listener" "nlb_listener" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.nlb.id
  port              = each.key
  protocol          = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.id
  }
}

