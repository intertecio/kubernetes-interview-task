resource "kubernetes_manifest" "eks_loadbalancer_controller_secret" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/alb_controller/secret.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "eks_loadbalancer_controller_service_account" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/manifests/alb_controller/service_account.yaml", {
    AWS_IAM_ROLE_ARN = aws_iam_role.eks_alb_controller_iam_role.arn
  }))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "eks_loadbalancer_controller_cluster_role" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/alb_controller/cluster_role.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "eks_loadbalancer_controller_cluster_role_binding" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/alb_controller/cluster_role_binding.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "eks_loadbalancer_controller_role" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/alb_controller/role.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "eks_loadbalancer_controller_role_binding" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/alb_controller/role_binding.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "ebs_csi_storage_class" {
  count = var.execute_general_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/ebs_csi_driver/storage_class.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_manifest" "argocd_ingress_controller" {
  count = var.execute_argocd_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/argocd/ingress.yaml"))
  depends_on = [aws_eks_cluster.cluster]
}

### Applications
resource "kubernetes_manifest" "application_namespace" {
  count = var.execute_argocd_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/argocd/applications/namespace.yaml"))
  depends_on = [aws_eks_cluster.cluster, helm_release.argocd]
}

resource "kubernetes_manifest" "argocd_blue_application" {
  count = var.execute_argocd_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/argocd/applications/blue-application.yaml"))
  depends_on = [aws_eks_cluster.cluster, helm_release.argocd, kubernetes_manifest.application_namespace]
}

resource "kubernetes_manifest" "argocd_green_application" {
  count = var.execute_argocd_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/argocd/applications/green-application.yaml"))
  depends_on = [aws_eks_cluster.cluster, helm_release.argocd, kubernetes_manifest.application_namespace]
}

resource "kubernetes_manifest" "application_ingress_controller" {
  count = var.execute_argocd_kubernetes_manifests ? 1 : 0

  manifest   = yamldecode(file("${path.module}/manifests/app_ingress.yaml"))
  depends_on = [kubernetes_manifest.argocd_blue_application, kubernetes_manifest.argocd_green_application]
}
