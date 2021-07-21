terraform {
  backend "s3" {
    bucket = "cf-templates-arixwmuk9m9w-us-east-2"
    key    = "terraform/front/terraform.tfstate"
    region = "us-east-2"
    # encrypt = true
    # kms_key_id = "THE_ID_OF_THE_KMS_KEY"
  }
}

provider "aws" {
  region = var.region
  # region = "eu-central-1"
  default_tags {
    tags = {
      ita_group = "Dp_206"
      Owner-1   = "Denis Dugar"
      Owner-2   = "Oleksandr Semeriaha"
      Owner-3   = "Andrew Handzha"
    }
  }
}

resource "aws_security_group" "what_front" {
  name        = "What-Front-Security-Group"
  description = "What Front Security Group"
  vpc_id      = data.aws_vpc.what_vpc.id

  dynamic "ingress" {
    for_each = ["80", "8080"]
    content {
      description = "HTTP to VPC"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
#   user_data       = file("user_data_what_front.sh")

#   lifecycle {
#     create_before_destroy = true
#   }
#  }
resource "aws_launch_configuration" "what_front" {
  name_prefix     = "Frontend-for-project-What-LC"
  image_id        = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.what_front.id]
  user_data       = file("user_data_what_front.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "what_front" {
  name                 = "${aws_launch_configuration.what_front.name}-ASG"
  launch_configuration = aws_launch_configuration.what_front.id
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  vpc_zone_identifier  = [data.aws_subnet.what_pub_subnet_a.id, data.aws_subnet.what_pub_subnet_b.id]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.what_front.id]

  lifecycle {
    create_before_destroy = true
  }
  # launch_template {
  #   id      = aws_launch_template.what_front.id
  #   # version = "$Latest"
  # }
  dynamic "tag" {
    for_each = {
      Name      = "What-Front-ASG"
      ita_group = "Dp_206"
      Owner-1   = "Denis Dugar"
      Owner-2   = "Oleksandr Semeriaha"
      Owner-3   = "Andrew Handzha"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
#=================ELB for a Front Instances start===================
resource "aws_elb" "what_front" {
  name = "Frontend-for-project-What-ELB"
  # availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  subnets         = [data.aws_subnet.what_pub_subnet_a.id, data.aws_subnet.what_pub_subnet_b.id]
  security_groups = [aws_security_group.what_front.id]
  # instances       = [aws_instance.what_front_a.id, aws_instance.what_front_b.id]
  listener {
    lb_port           = 80
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
#=================ELB for a Front Instances end===================
