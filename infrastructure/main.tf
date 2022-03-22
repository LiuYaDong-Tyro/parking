provider "aws" {
  region  = "ap-southeast-2"
  profile = "tw-aws-beach"
}

resource "aws_dynamodb_table" "car_parking_table" {
  name         = var.table_name
  billing_mode = var.table_billing_mode
  hash_key     = "car-state"
  range_key    = "time"
  attribute {
    name = "car-state"
    type = "S"
  }
  attribute {
    name = "time"
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
}

resource "aws_lambda_function" "cat_in_function" {
  filename = "car_in_match.zip"
  function_name = "do_enter"
  handler = "car_in_match.match"
  role = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.car_in_function_source.output_base64sha256
  runtime       = "python3.8"
}

data "archive_file" "car_in_function_source" {
  type        = "zip"
  source_file = "./car_in_match.py"
  output_path = "car_in_match.zip"
}

resource "aws_lambda_function" "cat_out_function" {
  filename = "car_out_match.zip"
  function_name = "do_calculate"
  handler = "car_out_match.calculate"
  role = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.car_out_function_source.output_base64sha256
  runtime       = "python3.8"
}

data "archive_file" "car_out_function_source" {
  type        = "zip"
  source_file = "./car_out_calculate.py"
  output_path = "car_out_calculate.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
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

