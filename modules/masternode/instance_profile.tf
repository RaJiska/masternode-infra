data "aws_caller_identity" "current" {}

resource "aws_iam_instance_profile" "ip" {
  name  = "${local.stack_name}-${var.name}"
  role  = module.instance_role.name
}

module "instance_role" {
  source = "../iam_role"

  name_prefix = "${local.stack_name}-${var.name}-"
  name        = "ec2-role"

  assume_role_policy  = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  attachments_arn   = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  policies          = [
    {
      name    = "self-assign-eip"
      policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssociateMasternodeEIP",
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:elastic-ip/${aws_eip.eip.id}"
    },
    {
      "Sid": "AssociateEIPToMasternodeInstance",
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Name": "masternode-${var.name}"
        }
      }
    },
    {
      "Sid": "DisassociateMasternodeEIPForMasternodeEIP",
      "Effect": "Allow",
      "Action": [
        "ec2:DisassociateAddress"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:elastic-ip/${aws_eip.eip.id}"
    },
    {
      "Sid": "DisassociateMasternodeEIPForMasternodeInterface",
      "Effect": "Allow",
      "Action": [
        "ec2:DisassociateAddress"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Name": "${local.stack_name}-${var.name}"
        }
      }
    }
  ]
}
EOF
    }
  ]
}