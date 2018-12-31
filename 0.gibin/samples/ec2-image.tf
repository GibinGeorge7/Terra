

#create EC2 instance using LATEST ubuntu AMI


provider "aws" {
  region = "us-east-2"
}

#query the AWS API for the latest Ubuntu Xenial AMI
data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

#define our instance
resource "aws_instance" "my_first_instance" {
    ami           = "${data.aws_ami.latest-ubuntu.id}"
    instance_type = "t2.micro"

    tags = {
    Name = "Terraform_aws1"
  }

}

