
#this group allows incoming TCP requests on port 8080 from the CIDR block 0.0.0.0/0. (so the security group above allows incoming requests on port 8080 from any IP).


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}