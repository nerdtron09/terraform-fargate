vpc = {
    cidr_block               = "10.0.0.0/16"
    public_subnet_1_cidr     = "10.0.1.0/24"
    public_subnet_2_cidr     = "10.0.2.0/24"
    private_subnet_1_cidr    = "10.0.3.0/24"
    private_subnet_2_cidr    = "10.0.4.0/24"
    name_tag                 = "P3-vpc-skillup"
}

bastion = {
    ssh_whitelist            = ["x.x.x.x/32"]
    ami                      = "ami-059b6d3840b03d6dd"
    instance_type            = "t2.micro"
    key_pair                 = "skillup"
    userdata_filename        = "bastion.sh"
    name_tag                 = "P3-bastion-skillup"
}

alb = {
    name_tag                 = "alb-skillup"
    fargate_fl               = true
}

targetgrp = {
    name_tag                 = "targetgrp-skillup"
    port                     = 8080
    protocol                 = "HTTP"
}

listener = {
    port                     = 80
    protocol                 = "HTTP"
}

task_role = {
    name                     = "P3-taskrole-skillup"
    policyname               = "P3-read-S3-SSM"
    policyfilename           = "read_S3_SSM.json"
}

task_definition = {
    name                     = "taskdef-skillup"
    memory                   = 512
    cpu                      = 256
    execution_role_arn       = "arn:aws:iam::12341234:role/ecsTaskExecutionRole"
}

container = {
    name                     = "container-skillup"
    port                     = 8080
    protocol                 = "tcp"
    image                    = "12341234.dkr.ecr.ap-northeast-1.amazonaws.com/test:phpv5"
}

cluster = {
    name                     = "cluster-skillup"
}
  
service = {
    name                     = "service-skillup"
    desired_count            = 2
    hc_grace_period_seconds  = 0
}

GBL_CLASS_0_value            = "SERVICE"
GBL_CLASS_1_value            = "test"

igw_name_tag                 = "P3-igw-skillup"
public_subnet_1_name_tag     = "P3-public-subnet-skillup-1"
public_subnet_2_name_tag     = "P3-public-subnet-skillup-2"
private_subnet_1_name_tag    = "P3-private-subnet-skillup-1"
private_subnet_2_name_tag    = "P3-private-subnet-skillup-2"
eip_nat_name_tag             = "eip-nat-skillup"
ngw_name_tag                 = "P3-nat-skillup"
public_rt_name_tag           = "P3-public-rt-skillup"
private_rt_name_tag          = "P3-private-rt-skillup"
bastion_sg_name_tag          = "P3-bastion-sg-skillup"
alb_sg_name_tag              = "P3-alb-sg-skillup"
private_sg_name_tag          = "P3-private-sg-skillup"