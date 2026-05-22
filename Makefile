.PHONY: help init plan apply destroy test scan-iac scan-image

help:
	@echo "Available commands:"
	@echo "  make init        - Initialize Terraform"
	@echo "  make plan        - Run Terraform plan"
	@echo "  make apply       - Deploy infrastructure to AWS"
	@echo "  make destroy     - Destroy infrastructure on AWS"
	@echo "  make test        - Run Python unit tests"
	@echo "  make scan-iac    - Run Checkov against Terraform code"
	@echo "  make scan-image  - Run Trivy against Dockerfile"

init:
	cd terraform/envs/dev && terraform init

plan:
	cd terraform/envs/dev && terraform plan

apply:
	cd terraform/envs/dev && terraform apply -auto-approve

destroy:
	cd terraform/envs/dev && terraform destroy -auto-approve

test:
	pytest app/tests/

scan-iac:
	checkov -d terraform/

scan-image:
	trivy config app/Dockerfile
