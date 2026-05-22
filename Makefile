.PHONY: help bootstrap-init bootstrap-plan bootstrap-apply init plan apply destroy test scan-iac scan-image scan-k8s validate

help:
	@echo "Available commands:"
	@echo "  make bootstrap-init  - Initialize bootstrap Terraform"
	@echo "  make bootstrap-plan  - Plan bootstrap Terraform"
	@echo "  make bootstrap-apply - Apply bootstrap Terraform"
	@echo "  make init        - Initialize dev Terraform with backend.hcl"
	@echo "  make plan        - Run Terraform plan"
	@echo "  make apply       - Deploy infrastructure to AWS"
	@echo "  make destroy     - Destroy infrastructure on AWS"
	@echo "  make test        - Run Python unit tests"
	@echo "  make validate    - Run Terraform validation"
	@echo "  make scan-iac    - Run Checkov against Terraform code"
	@echo "  make scan-image  - Run Trivy against Dockerfile"
	@echo "  make scan-k8s    - Run Kyverno CLI against hardened manifest"

bootstrap-init:
	cd terraform/bootstrap && terraform init

bootstrap-plan:
	cd terraform/bootstrap && terraform plan

bootstrap-apply:
	cd terraform/bootstrap && terraform apply

init:
	terraform -chdir=terraform/envs/dev init -backend-config ./backend.hcl

plan:
	terraform -chdir=terraform/envs/dev plan

apply:
	terraform -chdir=terraform/envs/dev apply -auto-approve

destroy:
	terraform -chdir=terraform/envs/dev destroy -auto-approve

test:
	pytest app/tests/ lambda/guardduty_finding_router/tests/

validate: export TF_DATA_DIR=.terraform-validate
validate:
	terraform fmt -check -recursive terraform
	terraform -chdir=terraform/envs/dev init -backend=false -reconfigure
	terraform -chdir=terraform/envs/dev validate -no-color

scan-iac:
	checkov -d terraform/ --framework terraform --skip-path terraform/envs/dev/.terraform --skip-check CKV_AWS_18,CKV_AWS_109,CKV_AWS_111,CKV_AWS_144,CKV_AWS_274,CKV_AWS_356,CKV_TF_1,CKV_TF_2,CKV2_AWS_56,CKV2_AWS_62,CKV2_AWS_64

scan-image:
	trivy config app/Dockerfile

scan-k8s:
	kyverno apply policies/kyverno --resource kubernetes/deployment.yaml
