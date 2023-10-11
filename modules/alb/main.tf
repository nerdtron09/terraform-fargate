resource "aws_lb" "this" {
  name               = var.alb.name_tag
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb.sg_ids
  subnets            = var.alb.subnets
}

resource "aws_lb_target_group" "this" {
  name               = var.targetgrp.name_tag
  port               = var.targetgrp.port
  protocol           = var.targetgrp.protocol
  vpc_id             = var.targetgrp.vpc_id
  target_type        = var.fargate_fl ? "ip" : "instance"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn  = aws_lb.this.arn
  port               = var.listener.port
  protocol           = var.listener.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}