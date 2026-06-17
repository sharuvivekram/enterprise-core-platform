terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Instantiate the Custom Network Module
module "production_vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  environment          = "Production"
}

# 2. Instantiate the Custom EKS Cluster Module
module "production_eks" {
  source             = "./modules/eks"
  environment        = "Production"
  vpc_id             = module.production_vpc.vpc_id
  private_subnet_ids = module.production_vpc.private_subnet_ids
}