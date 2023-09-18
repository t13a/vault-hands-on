.PHONY: my-app/up
my-app/up:
	kubectl apply -k manifests/my-app --wait

.PHONY: my-app/down
my-app/down:
	kubectl delete -k manifests/my-app --force --grace-period=0 --ignore-not-found --wait

.PHONY: my-app/test
my-app/test:
	curl \
		--fail \
		--cacert .my-root-ca/ca.crt \
		--resolve app.my.example:443:$(kind_container_ip_address) \
		--user 'alice:12345' \
		https://app.my.example
