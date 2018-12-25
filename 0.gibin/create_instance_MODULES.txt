provider "aws" {
  region = "eu-west-3"
}

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name           = "my-cluster"
  instance_count = 3
  ami                    = "ami-0e55e373"
  instance_type          = "t2.micro"
 # key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["sg-881369e0"]
  subnet_id              = "subnet-5eee3413"
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}