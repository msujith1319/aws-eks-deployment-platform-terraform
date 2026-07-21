
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.2"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  region = var.region
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  region          = var.region
  node_group_size = var.node_group_size
  node_group_name = var.node_group_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "bastion_host" {
  source = "./modules/bastion-host"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

module "s3-dynamodb" {
  source = "./modules/s3-dynamodb"

  bucket_name    = var.bucket_name
  dynamodb_table = var.dynamodb_table
}


module "helm" {
  source = "./modules/helm"

  cluster_name             = var.cluster_name
  region                   = var.region
  vpc_id                   = module.vpc.vpc_id
  alb_service_account_name = module.iam.alb_service_account_name

  depends_on = [module.iam]

}

module "iam" {
  source            = "./modules/iam"
  oidc_provider_arn = module.eks.oidc_provider_arn
  region            = var.region
}


module "waf-cdn-acm-route53" {
  source = "./modules/waf-cdn-acm-route53"

  region       = var.region
  domain_name  = var.domain_name
  web_acl_name = var.web_acl_name
  public_ip    = var.public_ip
  web_alb_name = var.web_alb_name
  cdn_name     = var.cdn_name
}