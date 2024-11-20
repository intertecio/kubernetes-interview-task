data "aws_eks_addon_version" "ebs_csi_driver_version" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.cluster.version
}

resource "aws_eks_addon" "eks_addons" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = data.aws_eks_addon_version.ebs_csi_driver_version.addon_name
  addon_version            = data.aws_eks_addon_version.ebs_csi_driver_version.version
  service_account_role_arn = aws_iam_role.eks_addon_ebs_csi_iam_role.arn
}
