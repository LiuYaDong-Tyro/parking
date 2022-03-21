provider "aws" {
  region  = "ap-southeast-2"
  profile = "tw-aws-beach"
}

resource "aws_dynamodb_table" "my_first_table" {
  name         = var.table_name
  billing_mode = var.table_billing_mode
  hash_key     = "employee-id"
  attribute {
    name = "employee-id"
    type = "S"
  }
  tags = {
    environment = var.environment
  }
}




