.DELETE_ON_ERROR:
MAKEFLAGS += --no-builtin-rules --no-builtin-variables
SHELL := /usr/bin/env bash -euo pipefail

include *.mk

.PHONY: up
up: \
	vault/up \
	kind/up \
	helm/up \
	terraform/up \
	my-app/up
	@echo
	@echo Setup completed successfully. You can now login to Vault.
	@echo
	@echo \> Address: $(vault_addr)
	@echo \> Token: $(vault_token)
	@echo

.PHONY: down
down: \
	terraform/down \
	kind/down \
	vault/down

env_json = jq -n \
		--arg KIND_CLUSTER_NAME '$(KIND_CLUSTER_NAME)' \
		--arg KUBECONFIG '$(KUBECONFIG)' \
		--arg VAULT_ADDR '$(vault_addr)' \
		--arg VAULT_TOKEN '$(vault_token)' \
		'$$ARGS.named'

.PHONY: export
export:
	@$(env_json) | jq -r 'to_entries|map("\(.key)=\(.value|@sh)")|"export \(join(" "))"'

.PHONY: unset
unset:
	@$(env_json) | jq -r 'to_entries|map(.key)|"unset \(join(" "))"'
