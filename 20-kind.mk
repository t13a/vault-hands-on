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

kind_container_ip_address = $(shell docker network inspect kind \
	| jq -re --arg name '$(KIND_CLUSTER_NAME)-control-plane' '.[0].Containers[]|select(.Name==$$name).IPv4Address|split("/")[0]')
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

.PHONY: kind/container-ip-address
kind/container-ip-address:
	@echo $(kind_container_ip_address)

.PHONY: kind/cluster-name
kind/cluster-name:
	@echo $(KIND_CLUSTER_NAME)

.PHONY: kind/kubeconfig
kind/kubeconfig:
	@echo $(KUBECONFIG)
