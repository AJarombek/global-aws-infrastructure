/**
 * S3 Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 1/20/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/s3"
    region = "us-east-1"
  }
}

resource "aws_iam_policy" "global-jarombek-io-policy" {
  name = "admin-policy"
  path = "/jarombek-io/"
  policy = "${file("../iam/policies/global-jarombek-io-policy.json")}"
}

resource "aws_iam_policy" "www-global-jarombek-io-policy" {
  name = "admin-policy"
  path = "/jarombek-io/"
  policy = "${file("../iam/policies/www-global-jarombek-io-policy.json")}"
}

resource "aws_s3_bucket" "global-jarombek-io" {
  bucket = "global-jarombek-io"
  acl = "public-read"
  policy = "${aws_iam_policy.global-jarombek-io-policy.policy}"

  tags {
    Name = "global.jarombek.io"
  }

  website {
    index_document = "index.json"
    error_document = "index.json"
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket" "www-global-jarombek-io" {
  bucket = "global-jarombek-io"
  acl = "public-read"
  policy = "${aws_iam_policy.www-global-jarombek-io-policy.policy}"

  tags {
    Name = "www.global.jenkins.io"
  }

  website {
    redirect_all_requests_to = "https://global.jenkins.io"
  }
}