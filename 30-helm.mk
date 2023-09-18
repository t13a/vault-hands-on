helm_releases := \
	cert-manager \
	external-secrets \
	ingress-nginx

.PHONY: helm/up
helm/up: $(addsuffix /install,$(helm_releases))

.PHONY: helm/down
helm/down: $(addsuffix /uninstall,$(helm_releases))

helm_release_is_installed = helm status $(1) -n $(2) -o json | jq -e '.info.status=="deployed"' > /dev/null

define helm_release_rules
.PHONY: $(1)/install
$(1)/install:
	if ! $(call helm_release_is_installed,$(1),$(2)); then helm install $(1) $(3) --repo $(4) -n $(2) $(5); fi

.PHONY: $(1)/uninstall
$(1)/uninstall:
	if $(call helm_release_is_installed,$(1),$(2)); then helm uninstall $(1) -n $(2); fi

endef
$(eval $(call helm_release_rules,cert-manager,cert-manager,cert-manager,https://charts.jetstack.io,--atomic --create-namespace --set installCRDs=true --set startupapicheck.enabled=false))
$(eval $(call helm_release_rules,external-secrets,external-secrets,external-secrets,https://charts.external-secrets.io,--atomic --create-namespace --set installCRDs=true))

$(eval $(call helm_release_rules,ingress-nginx,ingress-nginx,ingress-nginx,https://kubernetes.github.io/ingress-nginx,$$(ingress_nginx_install_opts)))
ingress_nginx_install_opts := \
	--atomic \
	--create-namespace \
	--set-json controller.extraArgs='{"watch-ingress-without-class":"true","publish-status-address":"localhost"}' \
	--set controller.hostPort.enabled=true \
	--set controller.service.external.enabled=false
