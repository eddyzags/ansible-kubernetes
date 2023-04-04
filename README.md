# ansible-kubernetes

## What?

This repository implements the infrastructure as a code to automate the deployment process of a Kubernetes cluster management software based on [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

![Ansible Kubernetes schema](./docs/img/ansible-kubernetes-schema.png)

Ansible-Kubernetes provides several key features:

* **Infrastructure as a code** to deploy a Kubernetes cluster composed of a control plane (`kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `etcd`), and workers nodes (`kubelet`, `kube-proxy`, and `docker`).

* **Single node deployment** to provision all the components (control plane & worker node) in a single server (Bare metal, VM, or a container) based on the Ansible inventory group.

* **Multi-node deployment** to provision all the components in multiple servers.

* **Public key infrastructure (PKI)** to automate the generation of certificates for every component.

* **Testing playbook** to ensure the proper execution of the Ansible provisionnement.

* **Vagrant support** to test the Ansible-Kubernetes provision locally.

## Why?

Ansible-kubernetes is optimized for learning purposes. Even though being able to provision a production environment is defined as a constraint for the implementation of this solution, you should rely on a more reliable tool to automate the deployment of a Kubernetes cluster, such as [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

## Who?

This `ansible-kubernetes` playbook can be useful for IT professionals, developers who just want to experiment, or get familiar with a Kubernetes cluster.
For example, I am using this playbook to provision my homelab sandbox where I can break things without too much consequences.
