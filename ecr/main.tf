/**
 * AWS Infrastructure for my Elastic Container Registry.
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/ecr"
    region = "us-east-1"
  }
}

resource "aws_ecr_repository" "docker-jarombek-io-repository" {
  name = "docker-jarombek-io"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "docker-jarombek-io-container-repository"
    Application = "all"
    Environment = "all"
  }
}

resource "aws_ecr_lifecycle_policy" "andrew-jarombek-repository-policy" {
  repository = aws_ecr_repository.docker-jarombek-io-repository.name
  policy = file("repo-policy.json")
}