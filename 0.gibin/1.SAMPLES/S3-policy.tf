
#create IAM user
#create IAM user policy for S3
#create S3 bucket
#create S3 bucket policy
#Upload files to S3 bucket



##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {default = "AWS-EC2-1"}
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


# S3 Bucket IAM user#
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

#S3 bucket 
resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.environment_tag}-${var.bucket_name}"
  acl = "private"
  force_destroy = true

      policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.environment_tag}-${var.bucket_name}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.write_user.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.environment_tag}-${var.bucket_name}",
                "arn:aws:s3:::${var.environment_tag}-${var.bucket_name}/*"
            ]
        }
    ]
}
EOF

  tags {
    Name = "${var.environment_tag}-web_bucket"
    BillingCode        = "${var.billing_code_tag}"
    Environment = "${var.environment_tag}"
  }

}


#Upload local file (index.html) to S3
resource "aws_s3_bucket_object" "website" {
  bucket = "${aws_s3_bucket.web_bucket.bucket}"
  key    = "/website/index.html"
  source = "./index.html"

}
#Upload local file (.png) to S3
resource "aws_s3_bucket_object" "graphic" {
  bucket = "${aws_s3_bucket.web_bucket.bucket}"
  key    = "/website/Globo_logo_Vert.png"
  source = "./Globo_logo_Vert.png"

}

##################################################################################
# OUTPUT
##################################################################################

output "s3-bucket-arn" {
    value = "${aws_s3_bucket.web_bucket.arn }"
}
output "s3-bucket-dom" {
    value = "${aws_s3_bucket.web_bucket.bucket_regional_domain_name }"
}