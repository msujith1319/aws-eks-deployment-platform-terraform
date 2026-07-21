
//This module creates an IAM Role specifically for Kubernetes Service Accounts (IRSA).
/*
It is present in the Iam module inside the submodule there is Submodule: iam-role-for-service-accounts in that copy the code and do some changes like 
for this go to inputs adn find attach_load_balancer_controller_policy = true and changing the name like these...
*/


module "alb_controller_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name = "iam-role-for-alb-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:service-account-for-alb-controller"]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

//Creates a Kubernetes Service Account and atached the iam role with permissions of ALB controller.

resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "service-account-for-alb-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_controller_irsa.arn
    }
  }
}



