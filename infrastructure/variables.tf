variable "table_name" {
  description = "car parking service"
  default     = "parking"
}

variable "table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  default     = "PAY_PER_REQUEST"
}

variable "environment" {
  description = "car parking environment"
  default     = "test"
}