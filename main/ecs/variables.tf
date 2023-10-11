variable "vpc" {
  type = object({
    cidr_block             = string
    public_subnet_1_cidr   = string
    public_subnet_2_cidr   = string
    private_subnet_1_cidr  = string
    private_subnet_2_cidr  = string
    name_tag               = string
  })
}

variable "bastion" {
  type = object({
    ssh_whitelist         = list(string)
    ami                   = string
    instance_type         = string
    key_pair              = string
    name_tag              = string
    userdata_filename     = string
  })
}

variable "alb" {
  type = object({
    name_tag              = string
    fargate_fl            = bool
  })
}

variable "targetgrp" {
  type = object({
    name_tag              = string
    port                  = number
    protocol              = string
  })
}

variable "listener" {
  type = object({
    port                  = number
    protocol              = string
  })
}

variable "task_role" {
  type = object({
    name                  = string
    policyname            = string
    policyfilename        = string
  })
}

variable "container" {
  type = object({
    name                     = string
    port                     = number
    protocol                 = string
    image                    = string
  })
}

variable "task_definition" {
  type = object({
    name                     = string
    memory                   = number
    cpu                      = number
    execution_role_arn     = string
  })
}

variable "cluster" {
  type = object({
    name                     = string
  })
}
  
variable "service" {
  type = object({
    name                     = string
    desired_count            = number
    hc_grace_period_seconds  = number
  })
}

variable "igw_name_tag" {
  type = string
}

variable "public_subnet_1_name_tag" {
  type = string
}

variable "public_subnet_2_name_tag" {
  type = string
}

variable "private_subnet_1_name_tag" {
  type = string
}

variable "private_subnet_2_name_tag" {
  type = string
}

variable "eip_nat_name_tag" {
  type = string
}

variable "ngw_name_tag" {
  type = string
}

variable "public_rt_name_tag" {
  type = string
}

variable "private_rt_name_tag" {
  type = string
}

variable "bastion_sg_name_tag" {
  type = string
}

variable "private_sg_name_tag" {
  type = string
}

variable "alb_sg_name_tag" {
  type = string
}

variable "GBL_CLASS_0_value" {
  type = string
}

variable "GBL_CLASS_1_value" {
  type = string
}










