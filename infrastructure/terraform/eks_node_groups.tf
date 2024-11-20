data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/amazon-linux-2023/arm64/standard/recommended/release_version"
}

resource "aws_eks_node_group" "node_groups" {
  cluster_name  = aws_eks_cluster.cluster.name
  subnet_ids    = aws_subnet.private_subnets.*.id
  node_role_arn = aws_iam_role.node_group_role.arn

  node_group_name = var.eks.node_group.name
  ami_type        = var.eks.node_group.ami_type
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  instance_types  = var.eks.node_group.instance_types
  disk_size       = var.eks.node_group.disk_size
  capacity_type   = var.eks.node_group.capacity_type

  scaling_config {
    min_size     = var.eks.node_group.scaling_config.min_size
    max_size     = var.eks.node_group.scaling_config.max_size
    desired_size = var.eks.node_group.scaling_config.desired_size
  }

  update_config {
    max_unavailable = var.eks.node_group.update_config.max_unavailable
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.nodegroup-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodegroup-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodegroup-AmazonEC2ContainerRegistryReadOnly
  ]

  tags = var.tags
}
