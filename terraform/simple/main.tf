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
resource "aws_ebs_volume" "what_front_a" {
  size              = "10"
  availability_zone = data.aws_availability_zones.available.names[0]

}
resource "aws_network_interface" "what_front_a" {
  subnet_id   = aws_subnet.what_pub_subnet_a.id
  security_groups = [aws_security_group.what_front.id]
  # vpc_security_group_ids = [aws_security_group.what_front.id]

  private_ips = ["10.0.10.10"]
  # security_groups = [aws_security_group.what_front.id]

  # attachment {
  #   instance     = aws_instance.what_front_a.id
  #   device_index = 1
  # }
}

resource "aws_instance" "what_front_a" {
  ami               = data.aws_ami.latest_ubuntu.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]

  # security_groups = [aws_security_group.what_front.id]
  # user_data       = file(user_data_what_front.sh)
  # vpc_security_group_ids = [aws_security_group.what_front.id]
  # ebs_block_device {
  #   tags        = aws_vpc.what_vpc.tags_all
  #   device_name = "/dev/sdb1"
  # }
  root_block_device {
    volume_size = "10"
    tags = {
      ita_group = "Dp_206"
    }
  }
  network_interface {
    network_interface_id = aws_network_interface.what_front_a.id
    device_index         = 0
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

  # security_groups = [aws_security_group.what_front.id]
  # user_data       = file(user_data_what_front.sh)
  vpc_security_group_ids = [aws_security_group.what_front.id]
  subnet_id              = aws_subnet.what_pub_subnet_b.id
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
  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   target              = "HTTP:8080/"
  #   timeout             = 3
  #   interval            = 10
  # }
  # tags = [
  #   {
  #     key                 = "ita_group"
  #     value               = "Dp_206"
  #     propagate_at_launch = true
  #   },
  # ]
}


resource "aws_vpc" "what_vpc" {
  cidr_block = "10.0.0.0/16"
  # tags = {
  #   Name = "What-VPC"
  # }
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
# resource "aws_default_subnet" "default_az0" {
#   availability_zone = data.aws_availability_zones.available.names[0]
# }
# resource "aws_default_subnet" "default_az1" {
#   availability_zone = data.aws_availability_zones.available.names[1]
# }
