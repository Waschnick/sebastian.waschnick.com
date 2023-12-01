terraform-init:
	rm -rf .terraform && AWS_PROFILE=waschi terraform init -backend-config=_environments/development.config

terraform-plan:
	AWS_PROFILE=ush-dev terraform plan -var-file=_environments/development.tfvars

terraform-apply:
	AWS_PROFILE=ush-dev terraform apply -var-file=_environments/development.tfvars
