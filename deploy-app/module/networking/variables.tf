# dùng để truyền biến vào (có thể biến tự định nghĩa hoặc biến lấy từ output.tf)
variable "vpc_cidr" {
  
}

variable "public_sn_count" {
  
}

variable "private_sn_count" {
  
}

# variable "cidr_block" {
  
# }
variable "access_ip" {
  
}

variable "db_subnet_group" {
  type = bool
  default = false
}