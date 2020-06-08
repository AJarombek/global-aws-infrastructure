/**
 * Ouput variables for the ALB needed for ECS
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

output "ecs-dependencies" {
  description = "Resources that the ECS module depends on"
  value = [
    aws_lb.jenkins-jarombek-io-lb,
    aws_lb_listener.jenkins-jarombek-io-lb-listener-http,
    aws_lb_listener.jenkins-jarombek-io-lb-listener-https,
    aws_lb_listener_certificate.jenkins-jarombek-io-lb-listener-wc-cert,
    aws_lb_target_group.jenkins-jarombek-io-lb-target-group
  ]
}

output "alb-security-group" {
  description = "Security Group for the ALB"
  value = aws_security_group.jenkins-jarombek-io-lb-security-group.id
}

output "alb-dns-name" {
  description = "DNS name for the ALB"
  value = aws_lb.jenkins-jarombek-io-lb.dns_name
}

output "alb-zone-id" {
  description = "Route53 Zone ID for the ALB"
  value = aws_lb.jenkins-jarombek-io-lb.zone_id
}

output "jenkins-jarombek-io-lb-target-group" {
  description = "Target Group for the jenkins-jarombek-io Load Balancer"
  value = aws_lb_target_group.jenkins-jarombek-io-lb-target-group.arn
}