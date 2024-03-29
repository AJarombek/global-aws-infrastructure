/**
 * Infrastructure for AWS Lambda layers shared amongst applications.
 * Author: Andrew Jarombek
 * Date: 1/29/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/lambda-layers"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/lambda-layers"
}

data "archive_file" "upload-picture-layer-zip" {
  source_dir  = "upload-picture-layer"
  output_path = "upload-picture-layer.zip"
  type        = "zip"
}

resource "null_resource" "aws-lambda-emails-layer-zip" {
  provisioner "local-exec" {
    command = "cd aws-lambda-emails-layer/nodejs && npm install && cd .. && zip -r9 ../aws-lambda-emails-layer.zip nodejs"
  }
}

resource "aws_lambda_layer_version" "upload-picture-layer" {
  layer_name          = "upload-picture-layer"
  filename            = "upload-picture-layer.zip"
  compatible_runtimes = ["nodejs", "nodejs10.x", "nodejs12.x"]
}

resource "aws_lambda_layer_version" "aws-lambda-emails-layer" {
  layer_name          = "aws-lambda-emails-layer"
  filename            = "aws-lambda-emails-layer.zip"
  compatible_runtimes = ["nodejs", "nodejs10.x", "nodejs12.x"]

  depends_on = [null_resource.aws-lambda-emails-layer-zip]
}