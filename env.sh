#!/bin/bash
set -e


SHA256_KIND=705c722b0a87c9068e183f6d8baecd155a97a9683949ca837c2a500c9aa95c63
SHA256_KUBECTL=b6769d8ac6a0ed0f13b307d289dc092ad86180b08f5b5044af152808c04950ae

declare -a urls=(
  "https://github.com/kubernetes-sigs/kind/releases/download/v0.18.0/kind-linux-amd64"
  "https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl"
)

function tool_download()
{
  # Download KIND
  wget -O kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.18.0/kind-linux-amd64"
  # Download Kubectl
  wget -O kubectl "https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl"

  if sha256sum -c SHA256SUMS; then
    sudo install -m 755 kind /usr/local/bin/kind
    sudo install -m 755 kubectl /usr/local/bin/kubectl
    kind version
    kubectl version --client=true
  else
    echo "Download fail, sha256 mismatch"
    exit 1
  fi

  rm -f kind
  rm -f kubectl
}

function docker_group()
{
  # Add the current user to the docker group
  sudo usermod -aG docker $USER
  if ! docker ps; then
    echo "Please log out and log back in for the group membership changes to take effect."
    exit 1
  fi
}

function clean()
{
  sudo rm -f /usr/local/bin/kind
  sudo rm -f /usr/local/bin/kubectl
}

function create_kind()
{
  if kind get kubeconfig --name k8slab > /dev/null 2>&1 ; then
    echo "cluster is up, please delete first if you want to recreate it."
  else
    kind create cluster --name "k8slab" --config config.yaml
  fi

  kubectl get nodes
}

function delete_kind()
{
  kind delete cluster --name k8slab

  kind get clusters
}

if [[ "$1" == "install" ]]; then
  echo "Installing reqired files"
  tool_download
  docker_group
elif [[ "$1" == "create" ]]; then
  echo "Creating KIND cluster k8slab"
  create_kind
elif [[ "$1" == "delete" ]]; then
  echo "Deleting KIND cluster k8slab"
  delete_kind
else
  echo "Usage:"
  echo "  $0 install -- Download needed tools and env setup"
  echo "  $0 create -- setup a KIND cluster"
  echo "  $0 delete -- delete a KIND cluster"
  echo "  $0 clean -- clean environment, tools, config...etc"
  exit 1
fi
