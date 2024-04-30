# chứa các thông tin định nghĩa service cần tạo

resource "aws_db_instance" "three_tier_db" {
  
    instance_class = var.instance_class
    allocated_storage = var.allocated_storage
    engine = "mysql"
    engine_version = var.db_version
    db_name = var.db_name
    username = var.db_user
    password = var.db_password
    db_subnet_group_name = var.db_subnet_group_name
    identifier = var.identifier
    skip_final_snapshot = var.skip_final_snapshot
    vpc_security_group_ids = [var.rds_sg]

    tags = {
      Name = "three_tier_db"
    }

}