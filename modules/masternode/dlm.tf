resource "aws_dlm_lifecycle_policy" "dlm" {
  description        = "DLM for ${local.stack_name}-${var.name}"
  execution_role_arn = module.dlm_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = [ "VOLUME" ]

    schedule {
      name = "2 days of snapshots"

      create_rule {
        interval      = 12
        interval_unit = "HOURS"
        times         = [ "09:00" ]
      }

      retain_rule {
        count = 4
      }

      tags_to_add = {
        Name = "${local.stack_name}-${var.name}"
      }

      copy_tags = false
    }

    target_tags = {
      Name = "${local.stack_name}-${var.name}"
    }
  }
}

module "dlm_role" {
  source = "../iam_role"

  name_prefix = "${local.stack_name}-${var.name}-"
  name        = "dlm-role"

  assume_role_policy  = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["dlm.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  policies          = [
    {
      name    = "manage-snapshots"
      policy  = <<EOF
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
      "Sid": "ManageMasternodeSnapshots",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:CreateSnapshots",
        "ec2:DeleteSnapshot",
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
    }
  ]
}
EOF
    }
  ]
}