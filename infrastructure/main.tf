provider "aws" {
#  access_key = "${var.access_key}"
#  secret_key = "${var.secret_key}"
  region = "south-east-2"
}

resource "aws_dynamodb_table" "my_first_table" {
  name        = var.table_name
  billing_mode = var.table_billing_mode
  hash_key       = "employee-id"
  attribute {
    name = "employee-id"
    type = "S"
  }
  tags = {
    environment       = var.environment
  }
}