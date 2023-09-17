.DELETE_ON_ERROR:
MAKEFLAGS += --no-builtin-rules --no-builtin-variables
SHELL := /usr/bin/env bash -euo pipefail

include *.mk

.PHONY: up
up: \
	vault/up \
	kind/up \
	helm/up \
	terraform/up

.PHONY: down
down: \
	kind/down \
	vault/down

.PHONY: exec
exec: EXEC_CMD_ARGS = bash
exec: export VAULT_ADDR = $(vault_addr)
exec: export VAULT_TOKEN = $(vault_token)
exec:
	exec $(EXEC_CMD_ARGS)
