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
}



resource "aws_iot_topic_rule" "car_out_rule" {
  name        = "car_out"
  description = "car out rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/car' where state = 'car_out'"
  sql_version = "2016-03-23"
}

