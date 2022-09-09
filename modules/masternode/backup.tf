resource "aws_backup_vault" "backup_vault" {
  name = "${local.stack_name}-${var.name}"

  tags = {
    Name = "${local.stack_name}-${var.name}"
  }
}

resource "aws_backup_plan" "backup_plan" {
  name = "${local.stack_name}-${var.name}"

  rule {
    rule_name         = "ebs-snapshots"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 1/1 ? * * *)"

    lifecycle {
      delete_after = 4
    }
  }

  tags = {
    Name = "${local.stack_name}-${var.name}"
  }
}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = module.backup_role.arn
  name         = "snapshot-ebs-${local.stack_name}-volumes"
  plan_id      = aws_backup_plan.backup_plan.id

  resources = [
    "arn:aws:ec2:*:*:volume/*"
  ]

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Name"
    value = "${local.stack_name}-${var.name}"
  }
}

# TODO:
# - Restrict Snapshot creation to masternode instances
# - Restrict tagging to specific tags + enforce it
module "backup_role" {
  source = "../iam_role"

  name_prefix = "${local.stack_name}-${var.name}-"
  name        = "backup-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  policies = [
    {
      name   = "manage-snapshots"
      policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CreateTagsForMasternodeSnapshots",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [ 
            "CreateSnapshot",
            "CreateSnapshots"
          ],
          "aws:RequestTag/Name": "${local.stack_name}-${var.name}"
        }
      }
    },
    {
      "Sid": "CreateMasternodeSnapshots",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:CreateSnapshots"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RetrieveMasternodeSnapshots",
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot",
        "ec2:DescribeTags",
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
    },
    {
      "Sid": "GetBackupableResources",
      "Effect": "Allow",
      "Action": [
        "tag:GetResources"
      ],
      "Resource": "*"
    }
  ]
}
EOF
    }
  ]
}