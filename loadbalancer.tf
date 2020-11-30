resource "aws_lb" "app_load_balancer" {
  name = "alb-ecs"
  subnets = [
    aws_subnet.subnet_public.id,
    aws_subnet.subnet_private_2.id
  ]
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.security-group.id]

  tags = {
    Application = "node"
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name = "alb-tg-node-ecs"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval = "90"
    protocol = "HTTP"
    matcher = "200-299"
    timeout = "20"
    path = "/"
    unhealthy_threshold = "2"
  }

}

resource "aws_lb_listener" "https_forward" {
  depends_on = [
    aws_lb_target_group.app_target_group
  ]
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

output "aws_lb_url" {
  value = aws_lb.app_load_balancer.dns_name
}