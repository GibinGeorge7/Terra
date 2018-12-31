# create EC2 Instance 
# create VPC ,subnets,route table , IGW
# create security group + rules


##################################################################################
# VARIABLES
##################################################################################

variable "aws_acckey" {}
variable "aws_seckey" {}
variable "aws_region" {default ="us-east-1"}
variable "aws_prikey_path" {}
variable "aws_pubkey_name" { default = "AWS-EC2-1"}
variable "vpc_cidr1" {default = "10.1.0.0/16"}
variable "vpc_subnet1" {default = "10.1.0.0/24"}
variable "vpc_subnet2" {default = "10.1.1.0/24"}
variable  "ec2_ami" {default = "ami-c58c1dd3"}



##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_acckey }"
  secret_key = "${var.aws_seckey}"
  region = "${var.aws_region}"
}

##################################################################################
# DATASOURCE
##################################################################################
data "aws_availability_zones" "AZ" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr1}"
  enable_dns_hostnames = "true"
  tags { Name ="Terra VPC"}
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags { Name ="Terra IGW"}

}

resource "aws_subnet" "subnet1" {
  cidr_block        = "${var.vpc_subnet1}"
  vpc_id            = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.AZ.names[0]}"
  tags { Name ="Terra SUBNET1"}
}

resource "aws_subnet" "subnet2" {
  cidr_block        = "${var.vpc_subnet2}"
  vpc_id            = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.AZ.names[1]}"
  tags { Name ="Terra SUBNET2" }
}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags { Name ="Terra RouteTable"}
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta-subnet2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name        = "nginx_sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  tags { Name ="Terra SG"}

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami           = "${var.ec2_ami}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]
  key_name        = "${var.aws_pubkey_name}"
  tags { Name ="Terra_NGINX_EC1"}

  connection {
    user        = "ec2-user"
    private_key = "${file(var.aws_prikey_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "echo '<html><head><title>Blue Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Blue Team</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = "${aws_instance.nginx1.public_dns}"
}