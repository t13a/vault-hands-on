# Vault hands-on

A [Hashicorp Vault](https://www.vaultproject.io/) hands-on resource.

## Features

- Runs as production mode on [Docker](http://docker.io/)
- Automatic initialization and unseal (**insecure**)
- Build [cert-manager](https://cert-manager.io/) and [External Secrets Operatior](https://external-secrets.io/) on [kind](https://kind.sigs.k8s.io/)
- Deploy sample web app protected by TLS and "Basic" HTTP authentication
- All instructions are implemented as code

## Getting started

### Prerequisites

- Docker Compose
- Nix

### Setup

Enter the shell.

```sh
$ nix-shell
```

Setup all components.

```
[nix-shell:~/vault-hands-on]$ make up
...
Setup completed successfully. You can now login to Vault.

> URL: http://172.17.58.2:8200
> Root Token: hvs.7AJD0GW7mYcjYIKqxmVPuhNw
```

After installation, you can access the Vault from your browser.

If you want to use CLIs, set environment variables by following command.

```sh
[nix-shell:~/vault-hands-on]$ eval $(make export)
```

CLIs are now available.

```sh
[nix-shell:~/vault-hands-on]$ docker compose ps
NAME                                    IMAGE                                 COMMAND                  SERVICE                CREATED             STATUS                    PORTS
vault-hands-on-vault-1                  hashicorp/vault                       "docker-entrypoint.s…"   vault                  32 minutes ago      Up 32 minutes (healthy)   0.0.0.0:8200->8200/tcp, :::8200->8200/tcp
vault-hands-on-vault-insecure-setup-1   vault-hands-on-vault-insecure-setup   "vault-insecure-setu…"   vault-insecure-setup   32 minutes ago      Up 32 minutes

[nix-shell:~/vault-hands-on]$ vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.14.2
Build Date      2023-08-24T13:19:12Z
Storage Type    file
Cluster Name    vault-cluster-078a0e72
Cluster ID      73c9dfb8-fa4b-433d-ab40-4f8809e9de15
HA Enabled      false

[nix-shell:~/vault-hands-on]$ kind get clusters
vault-hands-on

[nix-shell:~/vault-hands-on]$ kubectl get cert
NAME         READY   SECRET       AGE
my-app-tls   True    my-app-tls   50m

[nix-shell:~/vault-hands-on]$ kubectl get es
NAME                STORE        REFRESH INTERVAL   STATUS         READY
my-app-basic-auth   my-secrets   1h                 SecretSynced   True

[nix-shell:~/vault-hands-on]$ helm list -A
NAME                    NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
cert-manager            cert-manager            1               2023-09-18 18:50:29.994478542 +0900 JST deployed        cert-manager-v1.13.0    v1.13.0
external-secrets        external-secrets        1               2023-09-18 18:50:58.869526836 +0900 JST deployed        external-secrets-0.9.4  v0.9.4
```

### Test

```sh
[nix-shell:~/vault-hands-on]$ make my-app/test
curl \
        --fail \
        --cacert .my-root-ca/ca.crt \
        --resolve app.my.example:443:172.17.3.2 \
        --user 'alice:12345' \
        https://app.my.example
OK
```

### Teardown

Unset environment variables.

```sh
[nix-shell:~/vault-hands-on]$ eval $(make unset)
```

Teardown all components.

```sh
[nix-shell:~/vault-hands-on]$ make down
```

Leave the shell.

```sh
[nix-shell:~/vault-hands-on]$ exit
```
