# TODO: Restrict to Minimum once ports are known
resource "aws_security_group" "masternode_instance" {
  name        = "masternode-${var.name}-ec2"
  description = "Security group for instance ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65000
    protocol        = "tcp"
    cidr_blocks     = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "masternode-${var.name}-ec2"
  }
}