variable "task_role" {
  type = object({
    name                     = string
    policyname               = string
    policyfilename           = string
    })
}

variable "task_definition" {
  type = object({
    name                     = string
    memory                   = number
    cpu                      = number
    execution_role_arn       = string
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
    subnets                  = list(string)
    security_groups          = list(string)
    target_group_arn         = string
  })
}

variable "GBL_CLASS_0_value" {
  type = string
}

variable "GBL_CLASS_1_value" {
  type = string
}