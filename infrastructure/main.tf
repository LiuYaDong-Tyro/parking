provider "aws" {
  region  = "ap-southeast-2"
  profile = "tw-aws-beach"
}

resource "aws_dynamodb_table" "car_parking_table" {
  name         = var.table_name
  billing_mode = var.table_billing_mode
  hash_key     = "car_state"
  range_key    = "car_no"
  attribute {
    name = "car_state"
    type = "S"
  }
  attribute {
    name = "car_no"
    type = "S"
  }

  tags = {
    environment = var.environment
  }
}


resource "aws_iot_topic_rule" "car_in_rule" {
  name        = "car_in"
  description = "car in rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/car' where state = 'car_in'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.cat_in_function.arn
  }
}

resource "aws_iot_topic_rule" "car_out_rule" {
  name        = "car_out"
  description = "car out rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/car' where state = 'car_out'"
  sql_version = "2016-03-23"
  lambda {
    function_arn = aws_lambda_function.cat_out_function.arn
  }
}

resource "aws_lambda_function" "cat_in_function" {
  filename         = "car_in_match.zip"
  function_name    = "do_enter"
  handler          = "car_in_match.do_enter"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.car_in_function_source.output_base64sha256
  runtime          = "python3.8"
  timeout          = 100
}

data "archive_file" "car_in_function_source" {
  type        = "zip"
  source_file = "./car_in_match.py"
  output_path = "car_in_match.zip"
}

resource "aws_lambda_function" "cat_out_function" {
  filename         = "car_out_calculate.zip"
  function_name    = "do_calculate"
  handler          = "car_out_calculate.do_calculate"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.car_out_function_source.output_base64sha256
  runtime          = "python3.8"
  timeout          = 100
}

data "archive_file" "car_out_function_source" {
  type        = "zip"
  source_file = "./car_out_calculate.py"
  output_path = "car_out_calculate.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name                = "iam_for_lambda"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", "arn:aws:iam::aws:policy/AmazonSNSFullAccess"]
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_sns_topic" "car_info" {
  name            = "car_info"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "arn:aws:sns:ap-southeast-2:160071257600:car_info"
  protocol  = "email"
  endpoint  = "lei.zhu1@thoughtworks.com"
}