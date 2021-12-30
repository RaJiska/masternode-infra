resource "aws_iam_policy" "policies" {
  count = length(var.policies)
  
  name    = "${var.name_prefix}${var.policies[count.index].name}"
  path    = var.path
  policy  = var.policies[count.index].policy
}