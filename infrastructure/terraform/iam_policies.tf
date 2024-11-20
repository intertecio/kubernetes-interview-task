resource "aws_iam_role_policy" "eks_load_balancer_policy" {
  name   = "eks-alb-controller"
  role   = aws_iam_role.eks_alb_controller_iam_role.name
  policy = data.aws_iam_policy_document.eks_loadbalancer_policy.json
}
