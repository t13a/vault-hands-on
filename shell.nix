with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    curl
    gnumake
    jq
    kind
    kubectl
    kubernetes-helm
    terraform
    vault
  ];
  shellHook = ''
    alias k=kubectl
    source <(helm completion bash)
    source <(kind completion bash)
    source <(kubectl completion bash)
    complete -o default -F __start_kubectl k
    complete -C terraform terraform
    complete -C vault vault
  '';
}
