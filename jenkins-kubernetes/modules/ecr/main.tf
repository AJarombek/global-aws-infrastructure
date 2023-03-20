/**
 * Jenkins Docker image repository in Elastic Container Registry.
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

resource "aws_ecr_repository" "jenkins-jarombek-io-repository" {
  name                 = "jenkins-jarombek-io"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "jenkins-jarombek-io-container-repository"
    Application = "all"
    Environment = "all"
    Terraform   = var.terraform_tag
  }
}

resource "aws_ecr_lifecycle_policy" "jenkins-jarombek-io-repository-policy" {
  repository = aws_ecr_repository.jenkins-jarombek-io-repository.name
  policy     = file("${path.module}/repo-policy.json")
}