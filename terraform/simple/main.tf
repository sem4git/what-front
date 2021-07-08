terraform {
  backend "s3" {
    bucket  = "terraform-bucket-what"
    key     = "terraform/simple/terraform.tfstate"
    region  = "eu-central-1"
    # encrypt = true
    # kms_key_id = "THE_ID_OF_THE_KMS_KEY"
  }
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_availability_zones" "available" {}

provider "aws" {
  region = var.region
  # region = "eu-central-1"
  default_tags {
    tags = {
      ita_group = "Dp_206"
      Owner     = "Oleksandr Semeriaha"
    }
  }
}

resource "random_string" "rds_password_back" {
  length           = 16
  special          = true
  override_special = "!#*&"
}
# resource "aws_ssm_parameter" "rds_password_back" {
#   name        = "/prod/mysql"
#   description = "Master password for RDS Backend"
#   type        = "SecureString"
#   value       = random_string.rds_password_back.result
# }
resource "aws_network_interface" "what_front_a" {
  subnet_id       = aws_subnet.what_pub_subnet_a.id
  security_groups = [aws_security_group.what_front.id]
  # vpc_security_group_ids = [aws_security_group.what_front.id]

  # private_ips = ["10.0.10.10"]
}
resource "aws_network_interface" "what_front_b" {
  subnet_id       = aws_subnet.what_pub_subnet_b.id
  security_groups = [aws_security_group.what_front.id]
  # vpc_security_group_ids = [aws_security_group.what_front.id]

  # private_ips = ["10.0.10.10"]
}

resource "aws_instance" "what_front_a" {
  ami               = data.aws_ami.latest_ubuntu.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]
  # subnet_id         = aws_subnet.what_pub_subnet_a.id

  # security_groups = [aws_security_group.what_front.id]
  # user_data       = file(user_data_what_front.sh)
  # vpc_security_group_ids = [aws_security_group.what_front.id]
  # ebs_block_device {
  #   tags        = aws_vpc.what_vpc.tags_all
  #   device_name = "/dev/sdb1"
  # }
  root_block_device {
    volume_size = "10"
  }
  network_interface {
    network_interface_id = aws_network_interface.what_front_a.id
    device_index         = 0
  }
  volume_tags = {
    "ita_group" = "Dp_206"
  }

  # subnet_id = aws_subnet.what_pub_subnet_a.id
  tags = {
    Name = "Frontend-A"
  }
}
resource "aws_instance" "what_front_b" {
  ami               = data.aws_ami.latest_ubuntu.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[1]
  # subnet_id         = aws_subnet.what_pub_subnet_b.id

  # security_groups = [aws_security_group.what_front.id]
  # user_data       = file(user_data_what_front.sh)
  # vpc_security_group_ids = [aws_security_group.what_front.id]
  # ebs_block_device {
  #   tags        = aws_vpc.what_vpc.tags_all
  #   device_name = "/dev/sdb1"
  # }
  root_block_device {
    volume_size = "10"
  }
  network_interface {
    network_interface_id = aws_network_interface.what_front_b.id
    device_index         = 0
  }
  volume_tags = {
    ita_group = "Dp_206"
  }

  # subnet_id = aws_subnet.what_pub_subnet_b.id
  tags = {
    Name = "Frontend-B"
  }
}

resource "aws_security_group" "what_front" {
  name        = "What-Front-Security-Group"
  description = "What Front Security Group"
  vpc_id      = aws_vpc.what_vpc.id

  ingress {
    description = "HTTP to VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # cidr_blocks      = [aws_vpc.main.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_launch_template" "what_front" {
#   name            = "Frontend-for-project-What-LT"
#   image_id        = data.aws_ami.latest_ubuntu.id
#   instance_type   = var.instance_type
#   # security_groups = [aws_security_group.what_front.id]
#   # user_data       = file(user_data_what_front.sh)

#   lifecycle {
#     create_before_destroy = true
#   }
#  }
#resource "aws_launch_configuration" "what_front" {
#   name            = "Frontend-for-project-What-LC"
#   image_id        = data.aws_ami.latest_ubuntu.id
#   instance_type   = var.instance_type
#   security_groups = [aws_security_group.what_front.id]
#   # user_data       = file(user_data_what_front.sh)

#   lifecycle {
#     create_before_destroy = true
#   }
#   # tag = {
#   #     key                 = "ita_group"
#   #     value               = "Dp_206"
#   #     # propagate_at_launch = true
#   # }

#   # tag {
#   #   key                 = "ita_group"
#   #   value               = "Dp_206"
#   #   propagate_at_launch = true
#   # }
#   # tags = {
#   #   Name      = "What-Front-LC"
#   #   ita_group = "Dp_206"
#   #   Owner     = "Oleksandr Semeriaha"

#   # }
# }

# resource "aws_autoscaling_group" "what_front" {
#   name                 = "Frontend-for-project-What-ASG"
#   # launch_configuration = aws_launch_configuration.what_front.id
#   min_size             = 2
#   max_size             = 2
#   min_elb_capacity     = 2
#   vpc_zone_identifier  = [aws_subnet.what_pub_subnet_a.id, aws_subnet.what_pub_subnet_a.id]
#   health_check_type    = "EC2"
#   load_balancers       = [aws_elb.what_front.id]

#   lifecycle {
#     create_before_destroy = true
#   }
#   launch_template {
#     id      = aws_launch_template.what_front.id
#     # version = "$Latest"
#   }
#   # tags = {
#   #     ita_group = "Dp_206"
#   #     Owner     = "Oleksandr Semeriaha"
#   #   }
#   tag {
#     key                 = "ita_group"
#     value               = "Dp_206"
#     propagate_at_launch = true
#   }
#   # tags = [
#   #   {
#   #     key                 = "ita_group"
#   #     value               = "Dp_206"
#   #     propagate_at_launch = true
#   #   },
#   # ]
# }

resource "aws_elb" "what_front" {
  name = "Frontend-for-project-What-ELB"
  # availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  subnets         = [aws_subnet.what_pub_subnet_a.id, aws_subnet.what_pub_subnet_b.id]
  security_groups = [aws_security_group.what_front.id]
  instances       = [aws_instance.what_front_a.id, aws_instance.what_front_b.id]
  listener {
    lb_port           = 8080
    lb_protocol       = "http"
    instance_port     = 8080
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    target              = "HTTP:8080/"
    timeout             = 3
    interval            = 10
  }
}

resource "aws_security_group" "what_back" {
  name        = "What-Back-Security-Group"
  description = "What Back Security Group"
  vpc_id      = aws_vpc.what_vpc.id

  ingress {
    description = "HTTP to VPC"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    # cidr_blocks      = [aws_vpc.main.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_network_interface" "what_back_a" {
  subnet_id       = aws_subnet.what_pub_subnet_a.id
  security_groups = [aws_security_group.what_back.id]
  # vpc_security_group_ids = [aws_security_group.what_front.id]

  # private_ips = ["10.0.10.10"]
}
resource "aws_instance" "what_back_a" {
  ami               = data.aws_ami.latest_ubuntu.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]
  # subnet_id         = aws_subnet.what_pub_subnet_a.id

  # security_groups = [aws_security_group.what_front.id]
  # user_data       = file(user_data_what_front.sh)
  # vpc_security_group_ids = [aws_security_group.what_front.id]
  # ebs_block_device {
  #   tags        = aws_vpc.what_vpc.tags_all
  #   device_name = "/dev/sdb1"
  # }
  root_block_device {
    volume_size = "15"
  }
  network_interface {
    network_interface_id = aws_network_interface.what_back_a.id
    device_index         = 0
  }
  volume_tags = {
    "ita_group" = "Dp_206"
  }

  # subnet_id = aws_subnet.what_pub_subnet_a.id
  tags = {
    Name = "Backend-A"
  }
}
resource "aws_vpc" "what_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "What-VPC"
  }
  # tags = {
  #     ita_group = "Dp_206"
  #     Owner     = "Oleksandr Semeriaha"
  #   }
}

resource "aws_subnet" "what_pub_subnet_a" {
  vpc_id                  = aws_vpc.what_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "What-Public-Subnet-AZ-A"
  }
}
resource "aws_subnet" "what_pub_subnet_b" {
  vpc_id                  = aws_vpc.what_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "What-Public-Subnet-AZ-B"
  }
}
resource "aws_internet_gateway" "what_igw" {
  vpc_id = aws_vpc.what_vpc.id

  tags = {
    Name = "What-IGW"
  }
}
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.what_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.what_igw.id
  }

  tags = {
    Name = "What-Public-Route"
  }
}
resource "aws_route_table_association" "rta_a_pub" {
  subnet_id      = aws_subnet.what_pub_subnet_a.id
  route_table_id = aws_route_table.pub.id

}
resource "aws_route_table_association" "rta_b_pub" {
  subnet_id      = aws_subnet.what_pub_subnet_b.id
  route_table_id = aws_route_table.pub.id

}
resource "aws_subnet" "what_private_subnet_a" {
  vpc_id            = aws_vpc.what_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.11.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "What-Private-Subnet-AZ-A"
  }
}
resource "aws_subnet" "what_private_subnet_b" {
  vpc_id            = aws_vpc.what_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.21.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "What-Private-Subnet-AZ-B"
  }
}

resource "aws_nat_gateway" "what_nat_gw_a" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.what_private_subnet_a.id
}
resource "aws_nat_gateway" "what_nat_gw_b" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.what_private_subnet_b.id
}
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.what_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.what_nat_gw_a.id
  }

  tags = {
    Name = "What-Private-Route-A"
  }
}
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.what_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.what_nat_gw_b.id
  }

  tags = {
    Name = "What-Private-Route-B"
  }
}
resource "aws_route_table_association" "rta_private_a" {
  subnet_id      = aws_subnet.what_private_subnet_a.id
  route_table_id = aws_route_table.private_a.id

}
resource "aws_route_table_association" "rta_private_b" {
  subnet_id      = aws_subnet.what_private_subnet_b.id
  route_table_id = aws_route_table.private_b.id

}
resource "aws_db_subnet_group" "what_dbsg" {
  name       = "main"
  subnet_ids = [aws_subnet.what_private_subnet_a.id, aws_subnet.what_private_subnet_b.id]

  tags = {
    Name = "What-DB-subnet-group"
  }
}

resource "aws_db_instance" "db_backend" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "WhatProd"
  username             = "administrator"
  password             = random_string.rds_password_back.result
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  db_subnet_group_name = aws_db_subnet_group.what_dbsg.name

}
