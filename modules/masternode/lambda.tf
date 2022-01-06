data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

data "aws_lambda_layer_version" "awscli_layer" {
  layer_name = "AWS_CLI"
}

resource "aws_lambda_function" "update_lt" {
  filename      = data.archive_file.lambda.output_path
  function_name = local.lambda_name
  role          = module.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  layers        = [ data.aws_lambda_layer_version.awscli_layer.arn ]

  source_code_hash  = data.archive_file.lambda.output_base64sha256
  runtime           = "python3.8"
  memory_size       = 512
  timeout           = 30

  environment {
    variables = {
      LAUNCH_TEMPLATE_ID  = aws_launch_template.lt.id
    }
  }
}

module "lambda_role" {
  source = "../iam_role"

  name_prefix = "${local.stack_name}-${var.name}-"
  name        = "lambda-role"

  assume_role_policy  = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  policies          = [
    {
      name    = "edit-lt-with-mew-snapshot"
      policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CreateLogGroup",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Sid": "WriteLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_name}"
    },
    {
      "Sid": "ListLaunchTemplates",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EditLaunchTemplate",
      "Effect": "Allow",
      "Action": [
        "ec2:ModifyLaunchTemplate"
      ],
      "Resource": "${aws_launch_template.lt.arn}"
    }
  ]
}
EOF
    }
  ]
}