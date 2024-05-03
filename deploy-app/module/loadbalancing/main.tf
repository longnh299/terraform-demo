# chứa các thông tin định nghĩa service cần tạo
resource "aws_lb" "three_tier_lb" {
    name = "three_tier_lb"
    security_groups = var.lb_sg
    subnets = var.public_subnets 
    idle_timeout = 400

    depends_on = [ var.app_sg ]
}

resource "aws_lb_target_group" "three_tier_tg" {
    name = "three_tier_lb_tg"
    port = var.port
    protocol = var.protocol
    vpc_id = var.vpc_id

    lifecycle {
      ignore_changes = [ name ]
      create_before_destroy = true
    }
}

resource "aws_lb_listener" "three_tier_lb" {
    load_balancer_arn = aws_lb.three_tier_lb.arn
    port = var.port
    protocol = var.protocol
    default_action {
      type = "forward"
      target_group_arn = [aws_lb_target_group.three_tier_tg.arn]
    }

}