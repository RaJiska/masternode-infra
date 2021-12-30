resource "aws_autoscaling_group" "asg" {
  name                      = "masternode-${var.name}"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = false
  vpc_zone_identifier       = var.subnets

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "masternode-${var.name}"
        "propagate_at_launch" = true
      }
    ]
  )
}