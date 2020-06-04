/**
 * Ouput variables for the ALB needed for ECS
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

output "depended_on" {
  description = "Resources that other modules depend on"
  value = null_resource.dependency-setter.id
}

output "alb-security-group" {
  description = "Security Group for the ALB"
  value = aws_security_group.jenkins-jarombek-io-lb-security-group.id
}

output "jenkins-jarombek-io-lb-target-group" {
  description = "Target Group for the jenkins-jarombek-io Load Balancer"
  value = aws_lb_target_group.jenkins-jarombek-io-lb-target-group.arn
}