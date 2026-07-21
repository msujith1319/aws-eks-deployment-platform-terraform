resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = var.alb_service_account_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}


resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.8.2"

  values = [
    <<EOF
  server:
    service:
      type: LoadBalancer
  EOF
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd,
    helm_release.alb_controller
  ]

}


resource "helm_release" "argocd_imageupdater" {
  name       = "argocd-image-updater"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"


  depends_on = [
    kubernetes_namespace_v1.argocd,
    helm_release.argocd
  ]

}

resource "kubernetes_namespace_v1" "monitor" {
  metadata {
    name = "monitor"
  }
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  namespace  = "monitor"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    <<EOF
  grafana:
    service: 
      type: LoadBalancer
    additionalDataSources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki-gateway.logging.svc.cluster.local
      isDefault: false
  prometheus:
    service: 
      type: ClusterIP
  alertmanager:
    service:
      type: ClusterIP
  EOF
  ]

  depends_on = [
    kubernetes_namespace_v1.monitor,
    helm_release.argocd_imageupdater
  ]

}


# resource "kubernetes_namespace_v1" "logging" {
#   metadata {
#     name = "logging"
#   }
# }

# resource "helm_release" "loki" {
#   name       = "loki"
#   namespace  = kubernetes_namespace_v1.logging.metadata[0].name
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "loki"

#   values = [
#     <<EOF
# loki:
#   auth_enabled: false

# singleBinary:
#   replicas: 1

# gateway:
#   enabled: true
# EOF
#   ]

#   depends_on = [
#     kubernetes_namespace_v1.logging
#   ]
# }


# resource "helm_release" "promtail" {
#   name       = "promtail"
#   namespace  = kubernetes_namespace_v1.logging.metadata[0].name
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "promtail"

#   values = [
#     <<EOF
# config:
#   clients:
#     - url: http://loki-gateway.logging.svc.cluster.local/loki/api/v1/push
# EOF
#   ]

#   depends_on = [
#     helm_release.loki
#   ]
# }



resource "helm_release" "metrics_server" {
  name      = "metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
}



