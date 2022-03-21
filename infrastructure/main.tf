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




