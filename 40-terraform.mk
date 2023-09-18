tfvars_json := terraform.tfvars.json

.PHONY: terraform/up
terraform/up: \
	terraform/init \
	terraform/apply

.PHONY: terraform/down
terraform/down: \
	terraform/destroy \
	terraform/clean-tfvars

.PHONY: terraform/init
terraform/init:
	terraform init

.PHONY: terraform/apply
terraform/apply: terraform/build-tfvars
	terraform apply -auto-approve

.PHONY: terraform/destroy
terraform/destroy: terraform/build-tfvars
	terraform destroy -auto-approve

.PHONY: terraform/build-tfvars
terraform/build-tfvars:
	jq -n \
		--arg kubernetes_config_path '$(KUBECONFIG)' \
		--arg vault_address '$(vault_addr)' \
		--arg vault_token '$(vault_token)' \
		'$$ARGS.named' > $(tfvars_json)

.PHONY: terraform/clean-tfvars
terraform/clean-tfvars:
	rm -f $(tfvars_json)
