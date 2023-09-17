vault_container_name = $(shell docker compose ps --format=json | jq -r '.[]|select(.Service=="vault")|.Name')
vault_container_ip_address = $(shell docker inspect --format=json $(vault_container_name) \
	| jq -r '.[].NetworkSettings.Networks|to_entries[]|select(.key!="kind").value.IPAddress')
vault_addr = http://$(vault_container_ip_address):8200
vault_token = $(shell docker compose exec vault-insecure-setup vault-insecure-setup root-token)

.PHONY: vault/up
vault/up:
	docker compose up --wait

.PHONY: vault/down
vault/down:
	docker compose down -v

.PHONY: vault/addr
vault/addr:
	@echo $(call vault_addr)

.PHONY: vault/token
vault/token:
	@echo $(call vault_token)
