output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = aws_eks_node_group.main.status
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "ecr_jar_repository_url" {
  description = "URL of the ECR repository for JAR images"
  value       = aws_ecr_repository.jar.repository_url
}

output "ecr_native_repository_url" {
  description = "URL of the ECR repository for Native images"
  value       = aws_ecr_repository.native.repository_url
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "next_steps" {
  description = "Next steps after cluster creation"
  value = <<EOT
1. Configure kubectl: aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}
2. Deploy applications: kubectl apply -f ../k8s/
3. Deploy monitoring: ../deploy-monitoring.sh
4. Access ECR repositories:
   - JAR: ${aws_ecr_repository.jar.repository_url}
   - Native: ${aws_ecr_repository.native.repository_url}
EOT
}
