

#create 2 ec2 instances using LOOPS


##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {default ="us-east-1"}
variable "key_name" { default = "AWS-EC2-1"}
variable "instance_count" { default = 3 }
variable  "ec2_ami" {default = "ami-c58c1dd3"}
variable  "CUS" {default = "MP"}
variable  "ENV" {default = "TEST"}


##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key }"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}


resource "aws_instance" "ec2-NEWAPP" {
  count = "${var.instance_count}"
  ami = "${var.ec2_ami}"
  key_name        = "${var.key_name}"
  instance_type = "t2.micro"
  tags = {
    Name = "${var.CUS}-${var.ENV}-EC2-${count.index}"
  }
}

##################################################################################
# OUTPUT
##################################################################################

#show attribute - public DNS
output "aws_instance_pub_dns" {
    value = "${aws_instance.ec2-NEWAPP.*.public_dns}"
}

#show attribute - private DNS
output "aws_instance_pri_dns" {
    value = "${aws_instance.ec2-NEWAPP.*.private_dns}"
}