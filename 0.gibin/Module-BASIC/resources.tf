##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}


##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
module "vpc" {
  source = ".\\Modules\\vpc"
  name = "${var.environment_tag}"
  cidr = "${var.network_address_space}"
  azs = "${slice(data.aws_availability_zones.available.names,0,var.subnet_count)}"
  tags {
    BillingCode        = "${var.billing_code_tag}"
    Environment = "${var.environment_tag}"
  }
}

# SECURITY GROUPS #
resource "aws_security_group" "elb-sg" {
  name        = "nginx_elb_sg"
  vpc_id      = "${module.vpc.vpc_id}"

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment_tag}-elb-sg"
    BillingCode        = "${var.billing_code_tag}"
    Environment = "${var.environment_tag}"
  }

}

# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name        = "nginx_sg"
  vpc_id      = "${module.vpc.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.network_address_space}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment_tag}-nginx-sg"
    BillingCode        = "${var.billing_code_tag}"
    Environment = "${var.environment_tag}"
  }

}


# INSTANCES #
resource "aws_instance" "nginx" {
  count = "${var.instance_count}"
  ami           = "ami-c58c1dd3"
  instance_type = "t2.micro"
  subnet_id     = "${element(module.vpc.public_subnets,count.index % var.subnet_count)}"
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]
  key_name        = "${var.key_name}"
  tags {
    Name = "${var.environment_tag}-nginx-${count.index + 1}"
    BillingCode        = "${var.billing_code_tag}"
    Environment = "${var.environment_tag}"
  }

}
