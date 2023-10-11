provider "aws" {
  profile          = "default"
  region           = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket         = "bucket-skillup"
    key            = "statefile/key"
    region         = "ap-northeast-1"
    dynamodb_table = "dynamodb-skillup"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr_block

  tags = {
    Name = var.vpc.name_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name_tag
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.public_subnet_1_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_1_name_tag
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.public_subnet_2_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_2_name_tag
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.private_subnet_1_cidr
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = var.private_subnet_1_name_tag
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.private_subnet_2_cidr
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = var.private_subnet_2_name_tag
  }
}

resource "aws_eip" "nat" {
  tags = {
    "Name" : var.eip_nat_name_tag
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id           = aws_eip.nat.id
  subnet_id               = aws_subnet.public_subnet_2.id

  tags = {
    Name          = var.ngw_name_tag,
    "GBL_CLASS_0" = var.GBL_CLASS_0_value,
    "GBL_CLASS_1" = var.GBL_CLASS_1_value
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_name_tag
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = var.private_rt_name_tag 
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "alb_sg" {
  name          = "alb-security-group"
  description   = "Allow HTTP"
  vpc_id        = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.alb_sg_name_tag
  }
}

resource "aws_security_group" "bastion_sg" {
  name          = "bastion-security-group"
  description   = "Allow SSH from my IP"
  vpc_id        = aws_vpc.main.id

  ingress {
    from_port   = 49160
    to_port     = 49160
    protocol    = "tcp"
    cidr_blocks = var.bastion.ssh_whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.bastion_sg_name_tag
  }
}

resource "aws_security_group" "private_sg" {
  name              = "private-security-group"
  description       = "Allow traffic to private subnet"
  vpc_id            = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : var.private_sg_name_tag
  }
}

resource "aws_instance" "bastion" {
  ami                    = var.bastion.ami
  instance_type          = var.bastion.instance_type
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = var.bastion.key_pair
  user_data              = file("../../other/scripts/${var.bastion.userdata_filename}") 
  
  tags = {
    Name                 = var.bastion.name_tag
    "GBL_CLASS_0"        = var.GBL_CLASS_0_value
    "GBL_CLASS_1"        = var.GBL_CLASS_1_value  
  }
}

module "alb" {
  source = "../../modules/alb"

  alb = {
    name_tag             = var.alb.name_tag
    sg_ids               = [aws_security_group.alb_sg.id]
    subnets              = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id] 
  }
  
  targetgrp = {
    name_tag             = var.targetgrp.name_tag
    vpc_id               = aws_vpc.main.id 
    port                 = var.targetgrp.port
    protocol             = var.targetgrp.protocol
  }

  listener = {
    port                 = var.listener.port
    protocol             = var.listener.protocol
  }
  
  fargate_fl             = var.alb.fargate_fl
}

module "ecs" {
  source = "../../modules/ecs"

  task_role = {
    name                 = var.task_role.name
    policyname           = var.task_role.policyname
    policyfilename       = var.task_role.policyfilename
    }

  task_definition = {
    name                 = var.task_definition.name
    memory               = var.task_definition.memory
    cpu                  = var.task_definition.cpu
    execution_role_arn   = var.task_definition.execution_role_arn
  }

  container = {
    name                 = var.container.name
    port                 = var.container.port
    protocol             = var.container.protocol
    image                = var.container.image
  }

  cluster = {
    name                 = var.cluster.name
  }
  
  service = {
    name                 = var.service.name
    desired_count        = var.service.desired_count
    hc_grace_period_seconds = var.service.hc_grace_period_seconds
    subnets              = [aws_subnet.private_subnet_1.id,aws_subnet.private_subnet_2.id]
    security_groups      = [aws_security_group.private_sg.id]
    target_group_arn     = module.alb.targetgrp_arn
  }

  GBL_CLASS_0_value      = var.GBL_CLASS_0_value
  GBL_CLASS_1_value      = var.GBL_CLASS_1_value
}











