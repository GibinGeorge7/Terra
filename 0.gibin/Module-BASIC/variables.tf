##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "AWS-EC2-1"
}
variable "network_address_space" {
  default = "10.1.0.0/16"
}

variable "billing_code_tag" { default = "ACCT8675309" }
variable "environment_tag" { default = "DEV" }
variable "bucket_name" {}


variable "instance_count" {
  default = 2
}

variable "subnet_count" {
  default = 2
}

