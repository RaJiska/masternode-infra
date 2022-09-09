resource "aws_cloudwatch_event_rule" "snapshot" {
  name        = "${local.stack_name}-${var.name}-snapshot-taken"
  description = "Trigger launch template update when snapshot is taken"

  event_pattern = <<EOF
{
  "source": ["aws.backup"],
  "detail-type": ["Backup Job State Change"],
  "detail": {
    "resourceType": ["EBS"],
    "state": ["COMPLETED"],
    "backupVaultArn": ["${aws_backup_vault.backup_vault.arn}"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "tolambda" {
  rule      = aws_cloudwatch_event_rule.snapshot.name
  target_id = "LambdaToUpdateLT"
  arn       = aws_lambda_function.update_lt.arn
}