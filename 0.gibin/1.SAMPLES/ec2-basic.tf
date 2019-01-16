
#create ec2 instacne from AMI


provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "new_instance" {
  ami = "ami-0e55e373"
  instance_type = "t2.micro"
  tags {
    Name = "terra_aws1"
  }
}