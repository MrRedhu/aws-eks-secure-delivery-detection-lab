variable "region" {
  type        = string
  description = "AWS Region to deploy to"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
  default     = "dev"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "aws-eks-secure-delivery-detection-lab"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository (owner/repo) for OIDC trust"
  default     = "MrRedhu/aws-eks-secure-delivery-detection-lab"
}
