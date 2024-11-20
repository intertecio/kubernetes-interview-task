resource "aws_eks_cluster" "cluster" {
  name    = var.eks.cluster.name
  version = var.eks.cluster.version

  # Networking
  vpc_config {
    endpoint_private_access = var.eks.cluster.vpc_config.endpoint_private_access
    endpoint_public_access  = var.eks.cluster.vpc_config.endpoint_public_access
    subnet_ids              = aws_subnet.private_subnets.*.id
    public_access_cidrs     = var.eks.cluster.vpc_config.public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.eks.cluster.kubernetes_network_config.service_ipv4_cidr
    ip_family         = var.eks.cluster.kubernetes_network_config.ip_family
  }

  # Security
  role_arn = aws_iam_role.cluster_role.arn

  access_config {
    authentication_mode                         = var.eks.cluster.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.eks.cluster.access_config.bootstrap_cluster_creator_admin_permissions
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]

  tags = var.tags
}
