# xuất ra các output để sử dụng trong bối cảnh khác ví dụ như ip của con ec2

output "db_endpoint" {
  value = aws_db_instance.three_tier_db.endpoint
}