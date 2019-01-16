#create IAM user
#create IAM user policy


##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "AWS-EC2-1"
}

variable "billing_code_tag" {}
variable "environment_tag" {}
variable "bucket_name" {}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}



##################################################################################
# RESOURCES
##################################################################################


# S3 Bucket config#
resource "aws_iam_user" "write_user" {
    name = "${var.environment_tag}-s3-write-user"
    force_destroy = true
}

resource "aws_iam_access_key" "write_user" {
    user = "${aws_iam_user.write_user.name}"
}

resource "aws_iam_user_policy" "write_user_pol" {
    name = "write"
    user = "${aws_iam_user.write_user.name}"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.environment_tag}-${var.bucket_name}",
                "arn:aws:s3:::${var.environment_tag}-${var.bucket_name}/*"
            ]
        }
   ]
}
EOF

}


##################################################################################
# OUTPUT
##################################################################################

output "aws_s3user" {
    value = "${aws_iam_user.write_user.name}"
}
