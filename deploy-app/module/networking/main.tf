# chứa các thông tin định nghĩa service cần tạo

resource "aws_vpc" "three_tier_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true


    tags = {
      Name = "three_tier_vpc"
    }
}

data "aws_availability_zones" "available" {
  
}

resource "aws_internet_gateway" "three_tier_igw" {
    vpc_id = aws_vpc.three_tier_vpc.id

    tags = {
      Name = "three_tier_igw"
    }
}

resource "aws_subnet" "three_tier_public_subnets" {
    count = var.public_sn_count
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.123.${10 + count.index}.0/24"
    map_customer_owned_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
      Name = "three_tier_public_subnet_${count.index + 1}"
    }

}

resource "aws_route_table" "three_tier_public_rtb" {
    vpc_id = aws_vpc.three_tier_vpc.id

    tags = {
        Name = "three_tier_public_rtb"
    }
}


resource "aws_route" "public_subnets_rt" {
  route_table_id = aws_route_table.three_tier_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.three_tier_igw.id
}

resource "aws_route_table_association" "three_tier_public_assoc" {
    route_table_id = aws_route_table.three_tier_public_rtb.id
    count = var.public_sn_count
    subnet_id = aws_subnet.three_tier_public_subnets.id
}

resource "aws_eip" "three_tier_ngw" {

    domain = "vpc"
  
}

resource "aws_nat_gateway" "three_tier_vpc" {
    allocation_id = aws_eip.three_tier_ngw.id
    subnet_id = aws_subnet.three_tier_public_subnets.id
  
}

resource "aws_subnet" "three_tier_private_subnets" {
    vpc_id = aws_vpc.three_tier_vpc.id
    count = var.private_sn_count
    cidr_block = "10.123.${10+ count.index}.0/24"
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
      Name = "three_tier_private_subnet_${count.index + 1}"
    }

}

resource "aws_route_table" "three_tier_private_rtb" {
    vpc_id = aws_vpc.three_tier_vpc.id

    tags = {
        Name = "three_tier_private_rtb"
    }

}

resource "aws_route_table_association" "three_tier_private_assoc" {
    route_table_id = aws_route_table.three_tier_private_rtb.id
    count = var.private_sn_count
    subnet_id = aws_subnet.three_tier_private_subnets.id
}

resource "aws_subnet" "three_tier_private_db_subnet" {
    vpc_id = aws_vpc.three_tier_vpc.id
    count = var.private_sn_count
    cidr_block = "10.123.${20+ count.index}.0/24"
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
      Name = "three_tier_private_db_subnet_${count.index + 1}"
    }
}

# sg for bastion host
resource "aws_security_group" "three_tier_bastion_sg" {
    name = "three_tier_sg_bastion"
    vpc_id = aws_vpc.three_tier_vpc.id
    ingress = {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = var.access_ip
    } 

    
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }
}


# sg for lb
resource "aws_security_group" "three_tier_lb_sg" {
    name = "three_tier_sg_lb"
    vpc_id = aws_vpc.three_tier_vpc.id
    ingress = {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["0.0.0.0/0"]
    } 

    
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }
}

locals {
  port_in_80 = [
    80
  ]
  port_in_22 = [
    22
  ]

  port_in_3306 = [
    3306
  ]
}

# sg for front end
resource "aws_security_group" "three_tier_frontend_sg" {
    name = "three_tier_sg_fe"
    vpc_id = aws_vpc.three_tier_vpc.id

    dynamic "ingress" {
        for_each = toset(local.port_in_22)
        content {
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        security_groups = [aws_security_group.three_tier_bastion_sg.id]
        }
    }

    dynamic "ingress" {
        for_each = toset(local.port_in_80)
        content {
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        security_groups = [aws_security_group.three_tier_lb_sg.id]
        }
    }

    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }
}

# sg for back end
resource "aws_security_group" "three_tier_backend_sg" {
    name = "three_tier_sg_be"
    vpc_id = aws_vpc.three_tier_vpc.id

    dynamic "ingress" {
        for_each = toset(local.port_in_22)
        content {
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        security_groups = [aws_security_group.three_tier_bastion_sg.id]
        }
    }

    dynamic "ingress" {
        for_each = toset(local.port_in_80)
        content {
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        security_groups = [aws_security_group.three_tier_frontend_sg.id]
        }
    }

    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }
}

# sg for db
resource "aws_security_group" "three_tier_db_sg" {
    name = "three_tier_sg_db"
    vpc_id = aws_vpc.three_tier_vpc.id

    dynamic "ingress" {
        for_each = toset(local.port_in_3306)
        content {
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        security_groups = [aws_security_group.three_tier_backend_sg.id]
        }
    }

    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "three_tier_db" {
    count = var.db_subnet_group == true ? 1 : 0
    name = "db_sub_group"
    subnet_ids = [aws_subnet.three_tier_private_db_subnet[0].id]

    tags = {
      Name = "subnet_group_db"
    }
}

