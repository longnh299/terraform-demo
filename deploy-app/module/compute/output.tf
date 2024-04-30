# xuất ra các output để sử dụng trong bối cảnh khác ví dụ như ip của con ec2

output "app_asg" {
   value = aws_autoscaling_group.three_tier_app
}

output "backend_asg" {
    value = aws_autoscaling_group.three_tier_backend
}