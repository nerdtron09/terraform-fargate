module "task_role" {
    source = "../role"
    policy = {
        name               = var.task_role.policyname
        filename           = var.task_role.policyfilename
    }
    role = {
        name               = var.task_role.name
    }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_definition.name
  task_role_arn            = module.task_role.iam_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.task_definition.execution_role_arn
  memory                   = var.task_definition.memory
  cpu                      = var.task_definition.cpu
  container_definitions    = jsonencode([
        {
        name               = var.container.name
        portMappings       = [{
            hostPort       = var.container.port
            protocol       = var.container.protocol
            containerPort  = var.container.port
            }]
        image              = var.container.image
        disableNetworking  = false
        dockerLabels = {
            "GBL_CLASS_0"  = var.GBL_CLASS_0_value
            "GBL_CLASS_1"  = var.GBL_CLASS_1_value}
        }
    ])

  tags = {
    "GBL_CLASS_0"          = var.GBL_CLASS_0_value
    "GBL_CLASS_1"          = var.GBL_CLASS_1_value  
  }
}

resource "aws_ecs_cluster" "this" {
  name                     = var.cluster.name
  capacity_providers       = ["FARGATE"]

  tags = {
    "GBL_CLASS_0"          = var.GBL_CLASS_0_value
    "GBL_CLASS_1"          = var.GBL_CLASS_1_value  
  }
}

resource "aws_ecs_service" "this" {
  name                     = var.service.name
  launch_type              = "FARGATE"
  cluster                  = aws_ecs_cluster.this.id
  task_definition          = aws_ecs_task_definition.this.arn
  desired_count            = var.service.desired_count
  health_check_grace_period_seconds = var.service.hc_grace_period_seconds
  propagate_tags           = "TASK_DEFINITION"

  network_configuration {
    subnets                = var.service.subnets
    security_groups        = var.service.security_groups
  }

  load_balancer {
    target_group_arn       = var.service.target_group_arn
    container_name         = var.container.name
    container_port         = var.container.port
  }
}