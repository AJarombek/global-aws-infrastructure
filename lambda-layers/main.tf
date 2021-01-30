/**
 * Infrastructure for AWS Lambda layers shared amongst applications.
 * Author: Andrew Jarombek
 * Date: 1/29/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.26.0"
    archive = ">= 2.0.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/lambda-layers"
    region = "us-east-1"
  }
}

data "archive_file" "upload-picture-layer-zip" {
  source_dir = "upload-picture-layer"
  output_path = "upload-picture-layer.zip"
  type = "zip"
}

resource "aws_lambda_layer_version" "upload-picture-layer" {
  layer_name = "upload-picture-layer"
  filename = "upload-picture-layer.zip"
  compatible_runtimes = ["nodejs", "nodejs10.x", "nodejs12.x"]
}