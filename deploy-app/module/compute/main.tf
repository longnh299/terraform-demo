# chứa các thông tin định nghĩa service cần tạo

data "aws_ssm_parameter" "three_tier_ami" {
    name = "ssm_three_tier"
}

## launch template for bastion host
resource "aws_launch_template" "three_tier_basion" {

    name_prefix = "three_tier_basion"
    instance_type = var.instance_type
    image_id = data.aws_ssm_parameter.three_tier_ami.value
    vpc_security_group_ids = [var.bastion_sg]
    key_name = var.key_name   #ssh key name

    tags = {
      Name = "three_tier_basion"
    }
}

resource "aws_autoscaling_group" "three_tier_basion" {
    name = "three_tier_basion_asg"
    max_size = 1
    min_size = 1
    desired_capacity = 1  # desired_capacity <= max_size
    vpc_zone_identifier = var.public_subnets # subnet id to init ec2 instance

    launch_template {
      id = aws_launch_template.three_tier_basion.id # get id of launch template
      version = "$Latest"
    }
}

## launch template for front-end

resource "aws_launch_template" "three_tier_app" {

    name_prefix = "three_tier_app"
    instance_type = var.instance_type
    image_id = data.aws_ssm_parameter.three_tier_ami.value
    vpc_security_group_ids = [var.frontend_sg]
    key_name = var.key_name   #ssh key name

    user_data = filebase64("install_apache.sh")

    tags = {
      Name = "three_tier_app"
    }
}

data "aws_alb_target_group" "three_tier_tg"{
    name = var.alb_tg_name
}

resource "aws_autoscaling_group" "three_tier_app" {
    name = "three_tier_app_asg"
    max_size = 3
    min_size = 2
    desired_capacity = 2  # desired_capacity <= max_size
    vpc_zone_identifier = var.public_subnets # subnet id to init ec2 instance

    target_group_arns = [ data.aws_alb_target_group.three_tier_tg.arn ]

    launch_template {
      id = aws_launch_template.three_tier_app.id # get id of launch template
      version = "$Latest"
    }
}

## launch template for back-end

resource "aws_launch_template" "three_tier_backend" {

    name_prefix = "three_tier_backend"
    instance_type = var.instance_type
    image_id = data.aws_ssm_parameter.three_tier_ami.value
    vpc_security_group_ids = [var.backend_sg]
    key_name = var.key_name   #ssh key name

    user_data = filebase64("install_nodejs.sh")

    tags = {
      Name = "three_tier_backend"
    }
}

resource "aws_autoscaling_group" "three_tier_backend" {
    name = "three_tier_backend_asg"
    max_size = 3
    min_size = 2
    desired_capacity = 2  # desired_capacity <= max_size
    vpc_zone_identifier = var.private_subnets # subnet id to init ec2 instance

    target_group_arns = [ data.aws_alb_target_group.three_tier_tg.arn ]

    launch_template {
      id = aws_launch_template.three_tier_backend.id # get id of launch template
      version = "$Latest"
    }
}

