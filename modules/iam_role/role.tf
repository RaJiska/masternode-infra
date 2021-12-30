resource "aws_iam_role" "role" {
  name                = "${var.name_prefix}${var.name}"
  path                = var.path
  assume_role_policy  = var.assume_role_policy
}