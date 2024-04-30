# xuất ra các output để sử dụng trong bối cảnh khác ví dụ như ip của con ec2

output "alb_dns" {
  value = aws_lb.three_tier_lb.dns_name # get dns of lb
}

output "lb_endpoint" {
  value = aws_lb.three_tier_lb.dns_name
}

output "lb_tg_name" {
  value = aws_lb_target_group.three_tier_tg.name
}

output "lb_tg" {
  value = aws_lb_target_group.three_tier_tg.arn
}