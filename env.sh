#!/bin/bash
set -e

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

function verify_k8s()
{
	kubectl apply -f test                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    [22/3030]
	kubectl wait deployment/hwchiu-deployment --for=condition=available --timeout=5m

	number_of_sts=$(kubectl get statefulsets web -o jsonpath='{.spec.replicas}')
	echo $number_of_sts
	while true; do
		if [[ $number_of_sts == $(kubectl get pods --selector app=nginx | grep Running | wc -l) ]]; then
			echo "condition met"
			break
		fi
		sleep 5
	done

	kubectl cp test/index.html web-0:/usr/share/nginx/html/
	kubectl cp test/index.html web-1:/usr/share/nginx/html/
	kubectl cp test/index.html web-2:/usr/share/nginx/html/

	echo "Verify Network Access, NodrPort"
	curl -s localhost:8080 | grep "nginx test"
	echo "Verify Network Access, Ingress"
	curl -s myserver.hwchiu.com| grep "nginx test"

	echo "Removing testing applications"
	kubectl delete -f test
	kubectl delete pvc --all
	echo "-------------------------------------"
	echo "---- Pass Cluster Verification ------"
	echo "-------------------------------------"
}

if [[ "$1" == "install" ]]; then
	echo "Installing reqired files"
	tool_download
elif [[ "$1" == "create" ]]; then
	echo "Creating KIND cluster k8slab"
	create_kind
elif [[ "$1" == "delete" ]]; then
	echo "Deleting KIND cluster k8slab"
	delete_kind
elif [[ "$1" == "verify" ]]; then
	echo "Verify cluster setup"
	verify_k8s
else
	echo "Usage:"
	echo "  $0 install -- Download needed tools and env setup"
	echo "  $0 create -- setup a KIND cluster"
	echo "  $0 delete -- delete a KIND cluster"
	echo "  $0 clean -- clean environment, tools, config...etc"
	exit 1
fi
