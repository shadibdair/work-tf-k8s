.PHONY: help bootstrap-init bootstrap-apply tf-init tf-fmt tf-validate tf-plan tf-apply tf-state-list smoke-test

help:
	@echo "Available targets:"
	@echo "  bootstrap-init   - Initialize bootstrap Terraform"
	@echo "  bootstrap-apply  - Apply bootstrap Terraform"
	@echo "  tf-init          - Initialize main Terraform"
	@echo "  tf-fmt           - Format Terraform code"
	@echo "  tf-validate      - Validate Terraform code"
	@echo "  tf-plan          - Plan main Terraform changes"
	@echo "  tf-apply         - Apply main Terraform changes"
	@echo "  tf-state-list    - Show Terraform state resources"
	@echo "  smoke-test       - Run local smoke tests"

bootstrap-init:
	# Initializes terraform/bootstrap providers and modules.
	cd terraform/bootstrap && terraform init

bootstrap-apply:
	# Creates/updates local Minikube cluster and ingress addon.
	cd terraform/bootstrap && terraform apply

tf-init:
	cd terraform && terraform init

tf-fmt:
	cd terraform && terraform fmt -recursive
	cd terraform/bootstrap && terraform fmt -recursive

tf-validate:
	cd terraform && terraform validate
	cd terraform/bootstrap && terraform validate

tf-plan:
	cd terraform && terraform plan -var-file=environments/local.tfvars

tf-apply:
	# Applies the main stack (namespace, apps, services, ingress).
	cd terraform && terraform apply -var-file=environments/local.tfvars

tf-state-list:
	cd terraform && terraform state list

smoke-test:
	./scripts/smoke-test.sh