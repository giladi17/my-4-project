output "jenkins_public_ip" {
  description = "The public IP address of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "app_public_ip" {
  description = "The public IP address of the App server"
  value       = aws_instance.app.public_ip
}
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}