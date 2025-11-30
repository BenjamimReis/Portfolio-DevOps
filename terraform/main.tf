provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a","${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.0.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.26"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }

  tags = {
    Owner = "Portfolio-DevOps"
  }
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
