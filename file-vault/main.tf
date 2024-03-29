/**
 * S3 File Vault configuration.
 * Author: Andrew Jarombek
 * Date: 8/14/2021
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
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/vault-files"
    region  = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "andrew-jarombek-file-vault" {
  bucket = "andrew-jarombek-file-vault"

  tags = {
    Name        = "andrew-jarombek-file-vault"
    Application = "all"
    Environment = "all"
  }
}

resource "aws_s3_bucket_versioning" "andrew-jarombek-file-vault" {
  bucket = aws_s3_bucket.andrew-jarombek-file-vault.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "andrew-jarombek-file-vault" {
  bucket = aws_s3_bucket.andrew-jarombek-file-vault.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "andrew-jarombek-file-vault-policy" {
  bucket = aws_s3_bucket.andrew-jarombek-file-vault.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AndrewJarombekFileVaultPolicy"
    Statement = [
      {
        Sid    = "Permissions"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action   = ["s3:*"]
        Resource = ["${aws_s3_bucket.andrew-jarombek-file-vault.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "andrew-jarombek-file-vault" {
  bucket = aws_s3_bucket.andrew-jarombek-file-vault.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_object" "github-recovery-codes-txt" {
  bucket       = aws_s3_bucket.andrew-jarombek-file-vault.id
  key          = "github-recovery-codes.txt"
  source       = "objects/github-recovery-codes.txt"
  etag         = filemd5("objects/github-recovery-codes.txt")
  content_type = "text/plain"
}

resource "aws_s3_object" "kubeconfig_andrew-jarombek-eks-cluster" {
  bucket       = aws_s3_bucket.andrew-jarombek-file-vault.id
  key          = "kubeconfig_andrew-jarombek-eks-cluster"
  source       = "objects/kubeconfig_andrew-jarombek-eks-cluster"
  etag         = filemd5("objects/kubeconfig_andrew-jarombek-eks-cluster")
  content_type = "text/plain"
}

resource "aws_s3_object" "jetbrains-account-recovery-codes-txt" {
  bucket       = aws_s3_bucket.andrew-jarombek-file-vault.id
  key          = "jetbrains-account-recovery-codes.txt"
  source       = "objects/jetbrains-account-recovery-codes.txt"
  etag         = filemd5("objects/jetbrains-account-recovery-codes.txt")
  content_type = "text/plain"
}
