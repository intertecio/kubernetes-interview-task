# EKS LoadBalancer Controller
resource "helm_release" "eks_loadbalancer_controller" {
  count = var.execute_helm_releases ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  values = [templatefile("${path.module}/manifests/alb_controller/helm/values.yaml", {
    VPC_ID               = aws_vpc.vpc.id
    EKS_CLUSTER_NAME     = aws_eks_cluster.cluster.name
    SERVICE_ACCOUNT_NAME = kubernetes_manifest.eks_loadbalancer_controller_service_account[0].manifest.metadata.name
    IMAGE_TAG            = "v2.10.0"
  })]

  depends_on = [aws_iam_role_policy.eks_load_balancer_policy, aws_iam_role.eks_alb_controller_iam_role]
}

resource "helm_release" "argocd" {
  count = var.execute_helm_releases ? 1 : 0

  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  create_namespace = true
  values           = [file("${path.module}/manifests/argocd/helm/values.yaml")]

  depends_on = [helm_release.eks_loadbalancer_controller]
}
