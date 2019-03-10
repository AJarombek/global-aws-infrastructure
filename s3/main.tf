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

locals {
  # A unique identifier for the S3 origin.  This is needed for CloudFront.
  s3_origin_id = "globalJarombekIO"
}

#------------------------
# S3 Bucket Configuration
#------------------------

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

resource "aws_cloudfront_distribution" "global-jarombek-io-distribution" {
  origin {
    domain_name = "${aws_s3_bucket.global-jarombek-io.bucket_regional_domain_name}"
    origin_id = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity =
        "${aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path}"
    }
  }

  # Whether the cloudfront distribution is enabled to accept uer requests
  enabled = true

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "global.jarombek.io CloudFront Distribution"
  default_root_object = "index.json"

  # Extra CNAMEs for this distribution
  aliases = ["global.jarombek.io"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["HEAD", "GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["HEAD", "GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "${local.s3_origin_id}"

    # Which protocols to use which accessing items from CloudFront
    viewer_protocol_policy = "https-only"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["US"]
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags {
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "global.jarombek.io origin access identity"
}

#-------------------
# S3 Bucket Contents
#-------------------

resource "aws_s3_bucket_object" "index-json" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "index.json"
  source = "global/index.json"
  etag = "${md5(file("global/index.json"))}"
}

resource "aws_s3_bucket_object" "aws-key-gen" {
  bucket = "${aws_s3_bucket.global-jarombek-io.id}"
  key = "aws-key-gen.sh"
  source = "global/aws-key-gen.sh"
  etag = "${md5(file("global/aws-key-gen.sh"))}"
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