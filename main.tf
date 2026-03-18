terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

######################
# PROVIDER
######################
provider "aws" {
  region = var.region
}

######################
# AMI
######################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  # Match only Amazon Linux 2 images built for x86_64
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

######################
# VPC
######################
resource "aws_vpc" "techcorp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "techcorp-vpc" }
}

######################
# SUBNETS
######################
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.region}b"
}

######################
# INTERNET GATEWAY
######################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.techcorp_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

######################
# SECURITY GROUP
######################
resource "aws_security_group" "web_sg" {
  name        = "techcorp-web-sg"
  description = "Allow HTTP, HTTPS from internet + SSH from bastion"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Allow SSH from bastion"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_groups   = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-web-sg"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "techcorp-db-sg"
  description = "Allow Postgres from web+ SSH from bastion"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    description     = "Allow Postgres from web servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description     = "Allow SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-db-sg"
  }
}
resource "aws_security_group" "bastion_sg" {
  name   = "techcorp-bastion-sg"
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
 
######################
# BASTION HOST
######################
resource "aws_instance" "bastion_host" {
  ami           = "ami-05024c2628f651b80"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_1.id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = { Name = "techcorp-bastion" }
}

######################
# LOAD BALANCER
######################
resource "aws_lb" "techcorp_alb" {
  name               = "techcorp-alb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
  ]

  security_groups = [
    aws_security_group.web_sg.id
  ]

  tags = { Name = "techcorp-alb" }
}

resource "aws_instance" "web1" {
  ami           = "ami-05024c2628f651b80"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web-1"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-05024c2628f651b80"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web-2"
  }
}

resource "aws_instance" "db_server" {
  ami           = "ami-05024c2628f651b80"
  instance_type = "t3.small"

  subnet_id                 = aws_subnet.private_2.id
  vpc_security_group_ids    = [aws_security_group.db_sg.id]
  key_name                  = var.key_name

  user_data = file("user_data/db_server_setup.sh")

  tags = {
    Name = "techcorp-db"
  }
}

