variable "environment" { type = string }
variable "project" { type = string }
variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }
variable "kms_key_arn" { type = string }
variable "cluster_endpoint_public_access" {
  type    = bool
  default = false
}
variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}

module "eks" {
  # checkov:skip=CKV_TF_1:Using public registry version for lab
  # checkov:skip=CKV_TF_2:Using public registry version for lab
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}-${var.environment}"
  cluster_version = "1.35"

  vpc_id                               = var.vpc_id
  subnet_ids                           = var.private_subnets
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        nodeAgent = {
          healthProbeBindAddr = "8163"
          metricsBindAddr     = "8162"
        }
      })
    }
  }

  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn
  }

  eks_managed_node_groups = {
    app_nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}
