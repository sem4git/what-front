data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
data "aws_availability_zones" "available" {}

data "aws_vpc" "what_vpc" {
  tags = {
    Name = "VPC-VPC"
  }
}
data "aws_subnet" "what_pub_subnet_a" {
  tags = {
    Name = "Public_Subnet_1-VPC"
  }
}
data "aws_subnet" "what_pub_subnet_b" {
  tags = {
    Name = "Public_Subnet_2-VPC"
  }
}
data "aws_subnet" "what_private_subnet_a" {
  tags = {
    Name = "Private_Subnet_1-VPC"
  }
}
data "aws_subnet" "what_private_subnet_b" {
  tags = {
    Name = "Private_Subnet_2-VPC"
  }
}
