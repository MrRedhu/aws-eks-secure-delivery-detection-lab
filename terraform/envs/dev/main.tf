variable "region" { default = "us-east-1" }
variable "environment" { default = "dev" }
variable "project" { default = "aws-eks-secure-delivery-detection-lab" }
variable "github_repo" { default = "MrRedhu/aws-eks-secure-delivery-detection-lab" }

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Owner       = "ojash"
      ManagedBy   = "terraform"
      TTL         = "manual-destroy"
      CostCenter  = "portfolio-lab"
    }
  }
}

module "vpc" {
  source      = "../../modules/vpc"
  environment = var.environment
  project     = var.project
  region      = var.region
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
  project     = var.project
}

module "kms" {
  source      = "../../modules/kms"
  environment = var.environment
  project     = var.project
}

module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
  project     = var.project
  github_repo = var.github_repo
}

module "eks" {
  source          = "../../modules/eks"
  environment     = var.environment
  project         = var.project
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  kms_key_arn     = module.kms.key_arn
}

module "budget" {
  source      = "../../modules/budget"
  environment = var.environment
  project     = var.project
}
