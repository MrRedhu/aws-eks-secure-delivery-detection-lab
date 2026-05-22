variable "region" { default = "us-east-1" }
variable "environment" { default = "dev" }
variable "project" { default = "aws-eks-secure-delivery-detection-lab" }
variable "alert_email" { default = "aaryanredhu@gmail.com" }
variable "cluster_endpoint_public_access" { default = false }
variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}
variable "manage_aws_config_recorder" {
  type    = bool
  default = false
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Owner       = "Aryan"
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

module "eks" {
  source                               = "../../modules/eks"
  environment                          = var.environment
  project                              = var.project
  vpc_id                               = module.vpc.vpc_id
  private_subnets                      = module.vpc.private_subnets
  kms_key_arn                          = module.kms.key_arn
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
}

module "app_irsa" {
  source               = "../../modules/app-irsa"
  environment          = var.environment
  project              = var.project
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider        = module.eks.oidc_provider
  namespace            = "secure-demo"
  service_account_name = "secure-demo-sa"
}

module "budget" {
  source      = "../../modules/budget"
  environment = var.environment
  project     = var.project
  alert_email = var.alert_email
}

module "aws_config" {
  source                      = "../../modules/aws-config"
  environment                 = var.environment
  project                     = var.project
  manage_configuration_record = var.manage_aws_config_recorder
}

module "cloudtrail" {
  source      = "../../modules/cloudtrail"
  environment = var.environment
  project     = var.project
}

module "securityhub" {
  source      = "../../modules/securityhub"
  environment = var.environment
  project     = var.project

  depends_on = [module.aws_config]
}

module "detection" {
  source       = "../../modules/detection"
  environment  = var.environment
  project      = var.project
  cluster_name = module.eks.cluster_name
  alert_email  = var.alert_email
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_irsa_role_arn" {
  value = module.app_irsa.role_arn
}

output "security_alerts_topic_arn" {
  value = module.detection.sns_topic_arn
}
