

output "cluster_endpoint" {

  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.kubeconfig_certificate_authority_data
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "bastion-host-publicIP" {

  value = module.bastion_host.bastion_host_publicIP

}