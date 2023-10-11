data "aws_iam_policy_document" "this" {
  statement {
    actions       = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com",
                     "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "this" {
  name = var.policy.name
  policy = file("../../other/policies/${var.policy.filename}")
}

resource "aws_iam_role" "this" {
  name                       = var.role.name
  assume_role_policy         = data.aws_iam_policy_document.this.json
  managed_policy_arns        = [aws_iam_policy.this.arn]
}