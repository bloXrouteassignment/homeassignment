# dymanicaly retrieve AMI for Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true
  # account id that owns Ubuntu images
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/${var.os_type}-*"]
  }
}

# security group for EC2 instances
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow web traffic and restricted SSH access"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id] # only accept traffic from Load balancer
  }
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open to Internet, will need to be adjusted to exact CIDR of Ansible machine
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

# launch template for EC2 instances
resource "aws_launch_template" "web_template" {
  name          = "web-template"
  instance_type = var.instance_type
  image_id      = data.aws_ami.ubuntu.id
  # only allow inbound traffic from load balancer. Load balancer should check SSL certificates
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
              )
}

# autoscaling group
resource "aws_autoscaling_group" "web_asg" {
  name                = "web-asg"
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = var.subnets
  launch_template {
    id      = aws_launch_template.web_template.id
  }
  target_group_arns = [aws_lb_target_group.web_tg.arn]
}

# load balancer for instances. DNS name os this would be used to access EC2 instances
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets
}

resource "aws_security_group" "lb_sg" {
  name_prefix = "loadbalancer-sg-"
  
  # Allow incoming HTTP traffic, only for the assignment purposes, otherwise only HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 60
    timeout             = 15
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}


# IAM role and policy for EC2 to access backend resources if needed
resource "aws_iam_role" "ec2_role" {
  name = "my-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" { # policy is random need to be adjusted to the need of application
  name        = "my-ec2-policy"
  description = "Policy allowing EC2 to access S3 and RDS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListBucket", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-bucket/*"
      },
      {
        Action   = ["rds:DescribeDBInstances"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_policy_to_role" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}

# instance profile to be attached to launch template
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "my-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
