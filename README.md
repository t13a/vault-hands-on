# Vault hands-on

## Prerequisites

- Docker Compose
- Nix

## Getting started

### Setup

```sh
$ nix-shell
[nix-shell:~/vault-hands-on]$ make up
[nix-shell:~/vault-hands-on]$ eval $(make export)
```

### Teardown

```sh
[nix-shell:~/vault-hands-on]$ eval $(make unset)
[nix-shell:~/vault-hands-on]$ make down
[nix-shell:~/vault-hands-on]$ exit
```
