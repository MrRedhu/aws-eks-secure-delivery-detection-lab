.PHONY: test docker-build tf-fmt tf-validate checkov trivy-fs kyverno-scan

test:
	pytest app/tests

docker-build:
	docker build -t secure-demo-api:local app/

tf-fmt:
	cd terraform && terraform fmt -recursive

tf-validate:
	cd terraform/envs/dev && terraform init && terraform validate

checkov:
	checkov -d terraform --framework terraform

trivy-fs:
	trivy fs --scanners vuln,secret,misconfig .

kyverno-scan:
	kyverno apply policies/kyverno/ --resource kubernetes/
