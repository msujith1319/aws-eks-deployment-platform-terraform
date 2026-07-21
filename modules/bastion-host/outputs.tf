output "bastion_host_publicIP" {

  value = module.bastion_host.public_ip

}

output "vpc_id" {
  value = var.vpc_id
}

output "private_subnets" {
  value = var.private_subnets
}

output "public_subnets" {
  value = var.public_subnets
}