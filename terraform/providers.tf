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
