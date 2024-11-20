# EKS Cluster IAM role
resource "aws_iam_role" "cluster_role" {
  name               = "cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_role_policy_document.json
  tags               = var.tags
}

# EKS Node Group IAM role
resource "aws_iam_role" "node_group_role" {
  name               = "node_group_role"
  assume_role_policy = data.aws_iam_policy_document.node_group_role_policy_document.json
  tags               = var.tags
}

# EKS Addon(s) and Controller(s) IAM roles
resource "aws_iam_role" "eks_addon_ebs_csi_iam_role" {
  name               = "AmazonEKSEBSCSIDriverRole"
  assume_role_policy = data.aws_iam_policy_document.eks_addon_ebs_csi_iam_policy_document.json
}

resource "aws_iam_role" "eks_alb_controller_iam_role" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.eks_loadbalancer_controller_policy_document.json
}
