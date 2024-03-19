resource "aws_vpc" "vpc_long" {
    cidr_block = "10.0.0.0/16" # ipv4 class A, 16 bits network id  (all intance in this VPC has ip in range cidr_block) (10.0.0.0 -> 10.0.255.255)
    instance_tenancy = "default"

    tags = {
        Name = "vpc_long" # name of vpc want to create
    }
}

resource "aws_vpc" "long" {
    cidr_block = "10.0.0.0/16" # ipv4 class A, 16 bits network id  (all intance in this VPC has ip in range cidr_block) (10.0.0.0 -> 10.0.255.255)
    instance_tenancy = "default"

    tags = {
        Name = "vpc_long" # name of vpc want to create
    }
}

# name có thể giống nhau nhưng reference name phải khác nhau