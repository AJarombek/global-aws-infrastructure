/**
 * S3 Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 1/20/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/s3"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/s3"

  s3_object_tags = {
    Name        = "global.jarombek.io"
    Application = "global-jarombek-io"
    Environment = "production"
    Terraform   = local.terraform_tag
  }

  # A unique identifier for the S3 origin.  This is needed for CloudFront.
  s3_origin_id = "globalJarombekIO"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "jarombek-io-cert" {
  domain = "*.jarombek.io"
}

data "aws_route53_zone" "jarombek-io" {
  name = "jarombek.io."
}

#---------------------------------
# S3 Account Control Configuration
#---------------------------------

resource "aws_s3_account_public_access_block" "access" {
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#------------------------
# S3 Bucket Configuration
#------------------------

resource "aws_s3_bucket" "global-jarombek-io" {
  bucket = "global.jarombek.io"

  tags = {
    Name        = "global.jarombek.io"
    Application = "global-jarombek-io"
    Environment = "production"
    Terraform   = local.terraform_tag
  }
}

resource "aws_s3_bucket_website_configuration" "global-jarombek-io" {
  bucket = aws_s3_bucket.global-jarombek-io.id

  index_document {
    suffix = "index.json"
  }

  error_document {
    key = "index.json"
  }
}

resource "aws_s3_bucket_cors_configuration" "global-jarombek-io" {
  bucket = aws_s3_bucket.global-jarombek-io.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket_policy" "global-jarombek-io" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  policy = data.aws_iam_policy_document.global-jarombek-io.json
}

data "aws_iam_policy_document" "global-jarombek-io" {
  statement {
    sid = "CloudfrontOAI"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin-access-identity.iam_arn]
      type        = "AWS"
    }

    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.global-jarombek-io.arn,
      "${aws_s3_bucket.global-jarombek-io.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "global-jarombek-io" {
  bucket = aws_s3_bucket.global-jarombek-io.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_cloudfront_distribution" "global-jarombek-io-distribution" {
  origin {
    domain_name = aws_s3_bucket.global-jarombek-io.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept uer requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment             = "global.jarombek.io CloudFront Distribution"
  default_root_object = "index.json"

  # Extra CNAMEs for this distribution
  aliases = ["global.jarombek.io"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["HEAD", "GET", "OPTIONS"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["HEAD", "GET", "OPTIONS"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string = false
    }

    target_origin_id = local.s3_origin_id

    # Which protocols to use which accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.jarombek-io-cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name        = "global-jarombek-io-cloudfront"
    Application = "global-jarombek-io"
    Environment = "production"
    Terraform   = local.terraform_tag
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "global.jarombek.io origin access identity"
}

resource "aws_route53_record" "global-jarombek-io-a" {
  name    = "global.jarombek.io."
  type    = "A"
  zone_id = data.aws_route53_zone.jarombek-io.zone_id

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.global-jarombek-io-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.global-jarombek-io-distribution.hosted_zone_id
  }
}

#-------------------
# S3 Bucket Contents
#-------------------

resource "aws_s3_object" "index-json" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "index.json"
  source       = "global/index.json"
  etag         = filemd5("global/index.json")
  content_type = "application/json"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "aws-key-gen" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "aws-key-gen.sh"
  source       = "global/aws-key-gen.sh"
  etag         = filemd5("global/aws-key-gen.sh")
  content_type = "application/octet-stream"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "fonts-css" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts.css"
  source       = "global/fonts.css"
  etag         = filemd5("global/fonts.css")
  content_type = "text/css"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "allura-regular-otf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/Allura-Regular.otf"
  source       = "global/fonts/Allura-Regular.otf"
  etag         = filemd5("global/fonts/Allura-Regular.otf")
  content_type = "font/otf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "dyslexie-bold-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/dyslexie-bold.ttf"
  source       = "global/fonts/dyslexie-bold.ttf"
  etag         = filemd5("global/fonts/dyslexie-bold.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "elegant-icons-eot" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/ElegantIcons.eot"
  source       = "global/fonts/ElegantIcons.eot"
  etag         = filemd5("global/fonts/ElegantIcons.eot")
  content_type = "font/otf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "elegant-icons-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/ElegantIcons.ttf"
  source       = "global/fonts/ElegantIcons.ttf"
  etag         = filemd5("global/fonts/ElegantIcons.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "elegant-icons-woff" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/ElegantIcons.woff"
  source       = "global/fonts/ElegantIcons.woff"
  etag         = filemd5("global/fonts/ElegantIcons.woff")
  content_type = "font/woff"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "fantasque-sans-mono-bold-eot" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/FantasqueSansMono-Bold.eot"
  source       = "global/fonts/FantasqueSansMono-Bold.eot"
  etag         = filemd5("global/fonts/FantasqueSansMono-Bold.eot")
  content_type = "font/otf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "fantasque-sans-mono-bold-otf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/FantasqueSansMono-Bold.otf"
  source       = "global/fonts/FantasqueSansMono-Bold.otf"
  etag         = filemd5("global/fonts/FantasqueSansMono-Bold.otf")
  content_type = "font/otf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "fantasque-sans-mono-bold-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/FantasqueSansMono-Bold.ttf"
  source       = "global/fonts/FantasqueSansMono-Bold.ttf"
  etag         = filemd5("global/fonts/FantasqueSansMono-Bold.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "fantasque-sans-mono-bold-woff" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/FantasqueSansMono-Bold.woff"
  source       = "global/fonts/FantasqueSansMono-Bold.woff"
  etag         = filemd5("global/fonts/FantasqueSansMono-Bold.woff")
  content_type = "font/woff"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "fantasque-sans-mono-bold-woff2" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/FantasqueSansMono-Bold.woff2"
  source       = "global/fonts/FantasqueSansMono-Bold.woff2"
  etag         = filemd5("global/fonts/FantasqueSansMono-Bold.woff2")
  content_type = "font/woff2"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "longway-regular-otf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/Longway-Regular.otf"
  source       = "global/fonts/Longway-Regular.otf"
  etag         = filemd5("global/fonts/Longway-Regular.otf")
  content_type = "font/otf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "roboto-bold-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/Roboto-Bold.ttf"
  source       = "global/fonts/Roboto-Bold.ttf"
  etag         = filemd5("global/fonts/Roboto-Bold.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "roboto-regular-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/Roboto-Regular.ttf"
  source       = "global/fonts/Roboto-Regular.ttf"
  etag         = filemd5("global/fonts/Roboto-Regular.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "roboto-thin-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/Roboto-Thin.ttf"
  source       = "global/fonts/Roboto-Thin.ttf"
  etag         = filemd5("global/fonts/Roboto-Thin.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "robotoslab-bold-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/RobotoSlab-Bold.ttf"
  source       = "global/fonts/RobotoSlab-Bold.ttf"
  etag         = filemd5("global/fonts/RobotoSlab-Bold.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "robotoslab-light-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/RobotoSlab-Light.ttf"
  source       = "global/fonts/RobotoSlab-Light.ttf"
  etag         = filemd5("global/fonts/RobotoSlab-Light.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "robotoslab-regular-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/RobotoSlab-Regular.ttf"
  source       = "global/fonts/RobotoSlab-Regular.ttf"
  etag         = filemd5("global/fonts/RobotoSlab-Regular.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "robotoslab-thin-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/RobotoSlab-Thin.ttf"
  source       = "global/fonts/RobotoSlab-Thin.ttf"
  etag         = filemd5("global/fonts/RobotoSlab-Thin.ttf")
  content_type = "font/ttf"
  tags         = local.s3_object_tags
}

resource "aws_s3_object" "sylexiad-sans-thin-otf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/SylexiadSansThin.otf"
  source       = "global/fonts/SylexiadSansThin.otf"
  etag         = filemd5("global/fonts/SylexiadSansThin.otf")
  content_type = "font/otf"
}

resource "aws_s3_object" "sylexiad-sans-thin-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/SylexiadSansThin.ttf"
  source       = "global/fonts/SylexiadSansThin.ttf"
  etag         = filemd5("global/fonts/SylexiadSansThin.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_object" "sylexiad-sans-thin-bold-otf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/SylexiadSansThin-Bold.otf"
  source       = "global/fonts/SylexiadSansThin-Bold.otf"
  etag         = filemd5("global/fonts/SylexiadSansThin-Bold.otf")
  content_type = "font/otf"
}

resource "aws_s3_object" "sylexiad-sans-thin-bold-ttf" {
  bucket       = aws_s3_bucket.global-jarombek-io.id
  key          = "fonts/SylexiadSansThin-Bold.ttf"
  source       = "global/fonts/SylexiadSansThin-Bold.ttf"
  etag         = filemd5("global/fonts/SylexiadSansThin-Bold.ttf")
  content_type = "font/ttf"
}