resource "aws_launch_template" "lt" {
  name          = "masternode-${var.name}"
  description   = var.description
  image_id      = "ami-0ed9277fb7eb570c9"
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdb"

    ebs {
      volume_size           = var.blockchain_volume_size
      volume_type           = "gp2"
      snapshot_id           = var.blockchain_volume_snapshot
      delete_on_termination = true
      encrypted             = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ip.arn
  }

  disable_api_termination               = false
  instance_initiated_shutdown_behavior  = "terminate"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = false
  }

  vpc_security_group_ids = [ aws_security_group.masternode_instance.id ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name  = "masternode-${var.name}"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "masternode-${var.name}"
    }
  }

  user_data = filebase64("${path.module}/user_data.sh")

  lifecycle {
    ignore_changes = [ block_device_mappings.1.ebs.0.snapshot_id ]
  }
}

resource "aws_iam_instance_profile" "ip" {
  name  = "masternode-${var.name}"
  role  = module.instance_role.name
}

module "instance_role" {
  source = "../iam_role"

  name  = "${var.name}-role"
  path  = "/ec2/masternode/"

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
      name    = "ec2"
      policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ManageOwnEIP",
      "Effect": "Allow",
      "Action": [
        "ec2:AllocateAddress",
        "ec2:DisassociateAddress"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ARN": "$${ec2:SourceInstanceARN}"
        }
      }
    }
  ]
}
EOF
    }
  ]
}