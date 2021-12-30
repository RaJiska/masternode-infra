resource "aws_iam_role_policy_attachment" "attachment" {
  count = length(var.attachments_arn)

  role       = aws_iam_role.role.id
  policy_arn = var.attachments_arn[count.index]
}

resource "aws_iam_role_policy_attachment" "attachment_custom" {
  count = length(var.policies)

  role       = aws_iam_role.role.id
  policy_arn = aws_iam_policy.policies[count.index].arn
}