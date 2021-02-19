output "aws_region" {
  description = "AWS Region"
  value       = var.AWS_REGION
}


## CLUSTER
output "cluster_id" {
  description = "EKS Cluster Id"
  value       = aws_eks_cluster.peter_eks_cluster.id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.peter_eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = aws_iam_role.cluster_role.id
}


# NODE Group
output "eks_node_group_id" {
  description = "Node group Id"
  value       = aws_eks_node_group.eks_node_group.id
}

output "eks_node_group_status" {
  description = "Node group status"
  value       = aws_eks_node_group.eks_node_group.status
}


## WORKERS
output "worker_node_role_arn" {
  description = "IAM role ARN used by nodes."
  value       = aws_iam_role.worker_node_role.arn
}

output "worker_node_role_id" {
  description = "IAM role ID used by nodes."
  value       = aws_iam_role.worker_node_role.id
}

output "kubeconfig_certificate_authority_data" {
  description = "Kube config certificate data"
  value = aws_eks_cluster.peter_eks_cluster.certificate_authority[0].data
}


## KUBECONFIG OUTPUT

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.peter_eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.peter_eks_cluster.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.CLUSTER_NAME}"
KUBECONFIG
}

output "kubeconfig" {
  value = local.kubeconfig
}

# Join configuration

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.worker_node_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config-map-aws-auth" {
value = local.config-map-aws-auth
}

