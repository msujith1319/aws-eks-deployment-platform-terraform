variable "region" {

  default = "us-east-1"

}


variable "instance_type" {

  default = "t3.medium"

}

variable "project_name" {

  default = "devops_project"

}


variable "cluster_name" {

  default = "my-cluster"
}


variable "node_group_name" {

  default = "my-node-group"
}

variable "node_group_size" {

  default = 2
}


variable "public_ip" {

  default = "Your IP address"   // your ip address
}

variable "web_alb_name" {

  default = "ALB DNS name"    // your ALB DNS name  
}

variable "cdn_name" {

  default = "my-cdn"
}

variable "domain_name" {

  default = "example.com"     // your domain name 
}

variable "web_acl_name" {

  default = "my-web-acl"
}

variable "bucket_name" {

  default = "my-bucket"     // your bucket name 

}

variable "dynamodb_table" {

  default = "terraform-locks"

}