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

resource "aws_s3_bucket" "global-jarombek-io" {
  bucket = "global.jarombek.io"
  acl = "public-read"
  policy = "${file("../iam/policies/global-jarombek-io-policy.json")}"

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
  bucket = "www.global.jarombek.io"
  acl = "public-read"
  policy = "${file("../iam/policies/www-global-jarombek-io-policy.json")}"

  tags {
    Name = "www.global.jenkins.io"
  }

  website {
    redirect_all_requests_to = "https://global.jenkins.io"
  }
}

resource "aws_s3_bucket_object" "index-json" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "index.json"
  source = "global/index.json"
  etag = "${md5(file("global/index.json"))}"
}

resource "aws_s3_bucket_object" "fonts-css" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "fonts.css"
  source = "global/fonts.css"
  etag = "${md5(file("global/fonts.css"))}"
}

resource "aws_s3_bucket_object" "dyslexie-bold-ttf" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "fonts/dyslexie-bold.ttf"
  source = "global/fonts/dyslexie-bold.ttf"
  etag = "${md5(file("global/fonts/dyslexie-bold.ttf"))}"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-ttf" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "fonts/FantasqueSansMono-Bold.ttf"
  source = "global/fonts/FantasqueSansMono-Bold.ttf"
  etag = "${md5(file("global/fonts/FantasqueSansMono-Bold.ttf"))}"
}

resource "aws_s3_bucket_object" "longway-regular-otf" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "fonts/Longway-Regular.otf"
  source = "global/fonts/Longway-Regular.otf"
  etag = "${md5(file("global/fonts/Longway-Regular.otf"))}"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-ttf" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "fonts/SylexiadSansThin.ttf"
  source = "global/fonts/SylexiadSansThin.ttf"
  etag = "${md5(file("global/fonts/SylexiadSansThin.ttf"))}"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-bold-ttf" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "fonts/SylexiadSansThin-Bold.ttf"
  source = "global/fonts/SylexiadSansThin-Bold.ttf"
  etag = "${md5(file("global/fonts/SylexiadSansThin-Bold.ttf"))}"
}