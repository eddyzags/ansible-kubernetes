# ansible-kubernetes

## What?

This repository implements the infrastructure as a code to automate the deployment process of a Kubernetes cluster management software based on [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

![Ansible Kubernetes schema](./docs/img/ansible-kubernetes-schema.png)

Ansible-Kubernetes provides several key feaures:

* **Infrastructure as a code** to deploy a Kubernets cluster who is composed of a control plane (`kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `etcd`), and workers nodes (`kubelet`, `kube-proxy`, and `docker`).

* **Single node deployment** to provision all the components (control plane & worker node) in a single server (Bare metal, VM or a container) based on the Ansible inventory group.

* **Multi node deployment** to provision all the components in multiple servers.

* **Public key infrastructure (PKI)** to automate the generation of certificates for every components.

* **Testing playbook** to ensure that the provision has been executed properly.

* **Vagrant support** to test the Ansible-Kubernetes provisionnement locally.
