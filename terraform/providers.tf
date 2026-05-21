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
