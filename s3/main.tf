/**
 * S3 Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 1/20/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.37.0"
  }

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
  www_s3_origin_id = "wwwGlobalJarombekIO"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "global-jarombek-io-cert" {
  domain = "*.global.jarombek.io"
}

data "aws_acm_certificate" "jarombek-io-cert" {
  domain = "*.jarombek.io"
}

data "aws_route53_zone" "jarombek-io" {
  name = "jarombek.io."
}

#------------------------
# S3 Bucket Configuration
#------------------------

resource "aws_s3_bucket" "global-jarombek-io" {
  bucket = "global.jarombek.io"
  acl = "public-read"
  policy = file("../iam/policies/global-jarombek-io-policy.json")

  tags = {
    Name = "global.jarombek.io"
    Environment = "production"
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
  policy = file("../iam/policies/www-global-jarombek-io-policy.json")

  tags = {
    Name = "www.global.jenkins.io"
    Environment = "production"
  }

  website {
    redirect_all_requests_to = "https://global.jenkins.io"
  }
}

resource "aws_cloudfront_distribution" "global-jarombek-io-distribution" {
  origin {
    domain_name = aws_s3_bucket.global-jarombek-io.bucket_regional_domain_name
    origin_id = local.s3_origin_id

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

  comment = "global.jarombek.io CloudFront Distribution"
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
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string = false
    }

    target_origin_id = local.s3_origin_id

    # Which protocols to use which accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.jarombek-io-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "global-jarombek-io-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "global.jarombek.io origin access identity"
}

resource "aws_cloudfront_distribution" "www-global-jarombek-io-distribution" {
  origin {
    domain_name = aws_s3_bucket.www-global-jarombek-io.bucket_regional_domain_name
    origin_id = local.www_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity-www.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  comment = "www.global.jarombek.io CloudFront Distribution"
  default_root_object = "index.json"

  # Extra CNAMEs for this distribution
  aliases = ["www.global.jarombek.io"]

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
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string = false
    }

    target_origin_id = local.www_s3_origin_id

    # Which protocols to use which accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.global-jarombek-io-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "www-global-jarombek-io-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity-www" {
  comment = "www.global.jarombek.io origin access identity"
}

resource "aws_route53_record" "global-jarombek-io-a" {
  name    = "global.jarombek.io."
  type    = "A"
  zone_id = data.aws_route53_zone.jarombek-io.zone_id

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.global-jarombek-io-distribution.domain_name
    zone_id = aws_cloudfront_distribution.global-jarombek-io-distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "www-global-jarombek-io-a" {
  name = "www.global.jarombek.io."
  type = "A"
  zone_id = data.aws_route53_zone.jarombek-io.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.www-global-jarombek-io-distribution.domain_name
    zone_id = aws_cloudfront_distribution.www-global-jarombek-io-distribution.hosted_zone_id
  }
}

#-------------------
# S3 Bucket Contents
#-------------------

resource "aws_s3_bucket_object" "index-json" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "index.json"
  source = "global/index.json"
  etag = filemd5("global/index.json")
  content_type = "application/json"
}

resource "aws_s3_bucket_object" "aws-key-gen" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "aws-key-gen.sh"
  source = "global/aws-key-gen.sh"
  etag = filemd5("global/aws-key-gen.sh")
  content_type = "application/octet-stream"
}

resource "aws_s3_bucket_object" "fonts-css" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts.css"
  source = "global/fonts.css"
  etag = filemd5("global/fonts.css")
  content_type = "text/css"
}

resource "aws_s3_bucket_object" "allura-regular-otf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/Allura-Regular.otf"
  source = "global/fonts/Allura-Regular.otf"
  etag = filemd5("global/fonts/Allura-Regular.otf")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "dyslexie-bold-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/dyslexie-bold.ttf"
  source = "global/fonts/dyslexie-bold.ttf"
  etag = filemd5("global/fonts/dyslexie-bold.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "elegant-icons-eot" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/ElegantIcons.eot"
  source = "global/fonts/ElegantIcons.eot"
  etag = filemd5("global/fonts/ElegantIcons.eot")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "elegant-icons-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/ElegantIcons.ttf"
  source = "global/fonts/ElegantIcons.ttf"
  etag = filemd5("global/fonts/ElegantIcons.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "elegant-icons-woff" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/ElegantIcons.woff"
  source = "global/fonts/ElegantIcons.woff"
  etag = filemd5("global/fonts/ElegantIcons.woff")
  content_type = "font/woff"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-eot" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/FantasqueSansMono-Bold.eot"
  source = "global/fonts/FantasqueSansMono-Bold.eot"
  etag = filemd5("global/fonts/FantasqueSansMono-Bold.eot")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-otf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/FantasqueSansMono-Bold.otf"
  source = "global/fonts/FantasqueSansMono-Bold.otf"
  etag = filemd5("global/fonts/FantasqueSansMono-Bold.otf")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/FantasqueSansMono-Bold.ttf"
  source = "global/fonts/FantasqueSansMono-Bold.ttf"
  etag = filemd5("global/fonts/FantasqueSansMono-Bold.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-woff" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/FantasqueSansMono-Bold.woff"
  source = "global/fonts/FantasqueSansMono-Bold.woff"
  etag = filemd5("global/fonts/FantasqueSansMono-Bold.woff")
  content_type = "font/woff"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-woff2" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/FantasqueSansMono-Bold.woff2"
  source = "global/fonts/FantasqueSansMono-Bold.woff2"
  etag = filemd5("global/fonts/FantasqueSansMono-Bold.woff2")
  content_type = "font/woff2"
}

resource "aws_s3_bucket_object" "longway-regular-otf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/Longway-Regular.otf"
  source = "global/fonts/Longway-Regular.otf"
  etag = filemd5("global/fonts/Longway-Regular.otf")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "roboto-bold-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/Roboto-Bold.ttf"
  source = "global/fonts/Roboto-Bold.ttf"
  etag = filemd5("global/fonts/Roboto-Bold.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "roboto-regular-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/Roboto-Regular.ttf"
  source = "global/fonts/Roboto-Regular.ttf"
  etag = filemd5("global/fonts/Roboto-Regular.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "roboto-thin-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/Roboto-Thin.ttf"
  source = "global/fonts/Roboto-Thin.ttf"
  etag = filemd5("global/fonts/Roboto-Thin.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "robotoslab-bold-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/RobotoSlab-Bold.ttf"
  source = "global/fonts/RobotoSlab-Bold.ttf"
  etag = filemd5("global/fonts/RobotoSlab-Bold.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "robotoslab-light-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/RobotoSlab-Light.ttf"
  source = "global/fonts/RobotoSlab-Light.ttf"
  etag = filemd5("global/fonts/RobotoSlab-Light.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "robotoslab-regular-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/RobotoSlab-Regular.ttf"
  source = "global/fonts/RobotoSlab-Regular.ttf"
  etag = filemd5("global/fonts/RobotoSlab-Regular.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "robotoslab-thin-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/RobotoSlab-Thin.ttf"
  source = "global/fonts/RobotoSlab-Thin.ttf"
  etag = filemd5("global/fonts/RobotoSlab-Thin.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-otf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/SylexiadSansThin.otf"
  source = "global/fonts/SylexiadSansThin.otf"
  etag = filemd5("global/fonts/SylexiadSansThin.otf")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/SylexiadSansThin.ttf"
  source = "global/fonts/SylexiadSansThin.ttf"
  etag = filemd5("global/fonts/SylexiadSansThin.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-bold-otf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/SylexiadSansThin-Bold.otf"
  source = "global/fonts/SylexiadSansThin-Bold.otf"
  etag = filemd5("global/fonts/SylexiadSansThin-Bold.otf")
  content_type = "font/otf"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-bold-ttf" {
  bucket = aws_s3_bucket.global-jarombek-io.id
  key = "fonts/SylexiadSansThin-Bold.ttf"
  source = "global/fonts/SylexiadSansThin-Bold.ttf"
  etag = filemd5("global/fonts/SylexiadSansThin-Bold.ttf")
  content_type = "font/ttf"
}