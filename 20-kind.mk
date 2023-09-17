.PHONY: kind/up
kind/up: \
	kind/create \
	kind/connect-to-vault \
	kind/create-vault-service

.PHONY: kind/down
kind/down: \
	kind/disconnect-from-vault \
	kind/delete

export KIND_CLUSTER_NAME := vault-hands-on
export KUBECONFIG := $(PWD)/.kube/config

kind_is_created = kind get clusters | grep -q '^$(KIND_CLUSTER_NAME)$$'
kind_is_connected_to_vault = docker network inspect kind \
	| jq -e --arg name '$(vault_container_name)' '.[0].Containers[]|select(.Name==$$name)' > /dev/null

.PHONY: kind/create
kind/create:
	if ! $(kind_is_created); then kind create cluster; fi

.PHONY: kind/delete
kind/delete:
	if $(kind_is_created); then kind delete cluster; fi

.PHONY: kind/connect-to-vault
kind/connect-to-vault:
	if ! $(kind_is_connected_to_vault); then docker network connect kind $(vault_container_name); fi

.PHONY: kind/disconnect-from-vault
kind/disconnect-from-vault:
	if $(kind_is_connected_to_vault); then docker network disconnect kind $(vault_container_name); fi

.PHONY: kind/create-vault-service
kind/create-vault-service:
	kubectl create service externalname vault --external-name=$(vault_container_name) --dry-run=client -o yaml \
	| kubectl apply -f -

.PHONY: kind/delete-vault-service
kind/delete-vault-service:
	kubectl delete service vault --ignore-not-found

.PHONY: kind/cluster-name
kind/cluster-name:
	@echo $(KIND_CLUSTER_NAME)

.PHONY: kind/kubeconfig
kind/kubeconfig:
	@echo $(KUBECONFIG)

# vault_service_name := vault
# vault_service_namespace := default
# vault_server := http://$(vault_service_name).$(vault_service_namespace):8200

# .PHONY: vault-service/up
# vault-service/up: external_name=$(vault_container_name)
# vault-service/up:
# 	kubectl create service externalname $(vault_service_name) -n $(vault_service_namespace) --external-name=$(external_name) --dry-run=client -o yaml \
# 	| kubectl apply -f -

# .PHONY: vault-service/down
# vault-service/down:
# 	kubectl delete service $(vault_service_name) -n $(vault_service_namespace) --ignore-not-found

# .PHONY: olm/up
# olm/up:
# 	if ! operator-sdk olm status > /dev/null; then operator-sdk olm install; fi

# .PHONY: olm/down
# olm/down:
# 	if operator-sdk olm status > /dev/null; then operator-sdk olm uninstall; fi

# cert_manager_manifst := https://operatorhub.io/install/cert-manager.yaml

# .PHONY: cert-manager/up
# cert-manager/up:
# 	kubectl apply -f $(cert_manager_manifst)

# .PHONY: cert-manager/down
# cert-manager/down:
# 	kubectl delete -f $(cert_manager_manifst) --force=true --grace-period=0 --ignore-not-found=true

# external_secrets_manifest := https://operatorhub.io/install/external-secrets-operator.yaml

# .PHONY: external-secrets/up
# external-secrets/up:
# 	kubectl apply -f $(external_secrets_manifest)

# .PHONY: external-secrets/down
# external-secrets/down:
# 	kubectl delete -f $(external_secrets_manifest) --force=true --grace-period=0 --ignore-not-found=true
