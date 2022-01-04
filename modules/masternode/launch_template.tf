resource "aws_launch_template" "lt" {
  name          = "${local.stack_name}-${var.name}"
  description   = var.description
  image_id      = "ami-0ed9277fb7eb570c9"
  instance_type = var.instance_type
  key_name      = "main-rajiska"

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
      Name  = "${local.stack_name}-${var.name}"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${local.stack_name}-${var.name}"
    }
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = {
      Name = "${local.stack_name}-${var.name}"
    }
  }

  user_data = base64encode(data.template_file.user_data.rendered)

  lifecycle {
    ignore_changes = [ block_device_mappings.1.ebs.0.snapshot_id ]
  }
}

resource "aws_eip" "eip" {
  tags = {
    Name = "${local.stack_name}-${var.name}"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    EIP_ALLOCATION_ID = aws_eip.eip.allocation_id
    REGION            = var.region
  }
}