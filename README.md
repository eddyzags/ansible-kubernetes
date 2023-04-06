# ansible-kubernetes

## What?

This repository implements the infrastructure as a code to automate the deployment process of a Kubernetes cluster management software based on [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

![Ansible Kubernetes schema](./docs/img/ansible-kubernetes-schema.png)

`ansible-kubernetes` provides several key features:

* **Infrastructure as a code** to deploy a Kubernetes cluster composed of a control plane (`kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, and `etcd`), and workers nodes (`kubelet`, `kube-proxy`, and `docker`).

* **Single node deployment** to provision all the components (control plane & worker node) in a single server (Bare metal, VM, or a container) based on the Ansible inventory group.

* **Multi-node deployment** to provision all the components in multiple servers.

* **Public key infrastructure (PKI)** to automate the generation of certificates for every component.

* **Testing playbook** to ensure the proper execution of the Ansible provisionnement.

* **Vagrant support** to test the `ansible-kubernetes` provision locally.

* **Deprovisioning** to remove every traces produced by the `ansible-kubernetes` project.

## Why?

`ansible-kubernetes` is optimized for learning purposes. Even though being able to provision a production environment is defined as a constraint for the implementation of this solution, you should rely on a more reliable tool to automate the deployment of a Kubernetes cluster, such as [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

## Who?

This `ansible-kubernetes` playbook can be useful for IT operators, or developers who just want to experiment, or get familiar with a Kubernetes cluster.
For example, I am using this playbook to provision my homelab sandbox where I can break things without too much consequences.

## How?

### Provisioning

#### Installing dependencies

This section contains information on the requirements of `ansible-kubernetes` for the provision to function properly. To make it smooth, the `./scripts/deps_install.sh` sh script is implemented to install dependencies required by the `ansible-kubernetes` project. The script creates a `./output` folder to produce all the necessary software.

List of dependencies:

* `cfssljson`: A patch version with an additinal feature to output the certificates in a specific folder ([see feature pull request](https://github.com/cloudflare/cfssl/pull/1278))

Example usage:
```bash
$> ./scripts/deps_install.sh
```

#### Generate Transport Layer Security (TLS) certificates

In order to ensure a private communication between the different Kubernetes components, we will need to create a Private Key Infrastructure (PKI) using CloudFlare's PKI toolkit, `cfssl`. Then, use it to bootstrap a Certificate Authority (CA), and generate multiple Transport Layer Security (TLS) certificates for the following components: `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, `kubelet`, `kube-proxy`, `etcd`.
The `./scripts/certificates_gen.sh` sh script can be use to automate the certificates generation. This certificates will be output in the `./output/certs` folder.

> The ansible role will automatically know that the according certificates will remains in the ./output/certs folder.

Example usage:
```bash
$> ./script/certificates_gen.sh worker-0:192.168.1.1,worker-1:192.168.1.2,worker-3:192.168.1.2
```

#### Single node provisionning

Single node provisionning implements a mode to deploy all the Kubernetes components in a single server (Bare metal, container, or VM). This can be useful if your resources are limited, and you just want to spin up a Kubernetes quickly to experiment with it.

First of all, you'll need to specifify one IP address in which the Ansible agent will ssh in the inventory file:

```bash
[single-node]
192.169.1.2
```

Then, once the inventory is configured properly, you can start the provisionning by using the command below:

```bash
$> ansibe-playbook install.yml
```

#### Multi-node provisionning

_Work in progress_

### Deprovisioning

Once you don't need the Kubernetes cluster, you might need to shutdown, and remove, all the applications and configuration files related to the `ansible-kubernetes` project on your remote servers. In this case, the `uninstall.yml` playbook is implemented for this specific use case. It doesn't matter if you are in a single or multi node provisionning, the Ansible agent will ssh through every remote hosts, then execute the according task to remove every traces of the Kubernetes cluster.

Example usage:
```bash
$> ansible-playbook uninstall.yml
```

### Testing

#### Provision using Vagrant

The combinaison of Ansible and Vagrant is powerful when it comes to spin off virtual machines to test your Ansible playbook. We can seemlessly instruct Vagrant to execute an Ansible playbook once the virtual machines are up and running.

Example usage:
```bash
$> vagrant up
```

#### Testing provision

The `install.yml` playbook provides a way to test the deployment of the your Kubernetes cluster. It will make sure that the service are up and running using reliable methods (Example for the Kubernetes components: query `/livez` `/healthz` or `/readyz` http endpoints)

```bash
$> ansible-playbook install.yml --tags test
```
