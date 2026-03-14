provider "aws" {
  region = var.region
}

# ---------------------
# VPC
# ---------------------
resource "aws_vpc" "techcorp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "techcorp-vpc"
  }
}

# ---------------------
# Subnets
# ---------------------
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "techcorp-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "techcorp-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "techcorp-private-subnet-2"
  }
}

# ---------------------
# Internet Gateway
# ---------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.techcorp_vpc.id

  tags = {
    Name = "techcorp-igw"
  }
}

# ---------------------
# Security Groups
# ---------------------

# Bastion SG
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web SG
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database SG
resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
}

# ---------------------
# Bastion Host
# ---------------------
resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "techcorp-bastion"
  }
}

# ---------------------
# Web Servers
# ---------------------
resource "aws_instance" "web1" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web1"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_2.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web2"
  }
}

# ---------------------
# Database Server
# ---------------------
resource "aws_instance" "db" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.private_subnet_1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  user_data = file("user_data/db_server_setup.sh")

  tags = {
    Name = "techcorp-db"
  }
}

# ---------------------
# Application Load Balancer
# ---------------------
resource "aws_lb" "alb" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.techcorp_vpc.id
}

# Attach Web Servers
resource "aws_lb_target_group_attachment" "web1_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
