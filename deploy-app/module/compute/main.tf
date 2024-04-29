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
      id = aws_launch_template.three_tier_basion.id # get id of above autoscalinggroup
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