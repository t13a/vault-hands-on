.PHONY: terraform/up
terraform/up: \
	terraform/init \
	terraform/apply

.PHONY: terraform/down
terraform/down: \
	terraform/destroy

.PHONY: terraform/init
terraform/init:
	terraform init

.PHONY: terraform/apply
terraform/apply: terraform/tfvars
	terraform apply -auto-approve

.PHONY: terraform/destroy
terraform/destroy: terraform/tfvars
	terraform destroy -auto-approve

.PHONY: terraform/tfvars
terraform/tfvars:
	jq -n \
		--arg kubernetes_config_path '$(KUBECONFIG)' \
		--arg vault_address '$(vault_addr)' \
		--arg vault_token '$(vault_token)' \
		'$$ARGS.named' > terraform.tfvars.json
