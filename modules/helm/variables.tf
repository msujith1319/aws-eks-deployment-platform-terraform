variable "region" {}
variable "cluster_name" {}
variable "vpc_id" {}
variable "alb_service_account_name" {
  default = "alb-controller"
}