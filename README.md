# k8s hard way

Automated way of setting up Kubernetes cluster based on
Kelsey's Hightower [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) tutorial.


---

## Purpose

Everything in this repository was created **for learning purpose only**.

## Overview

Repository contains configuration files for two automation tools: Terraform and Ansible.

* **Terraform** will provision all necessary infrastructure, including VMs, LBs, network routes etc. It will also populate Ansible inventory files with VM IP addresses, public cluster IP address etc.


* **Ansbile** playbook, along with inventory, will install all necessary software and configuration files on a controller and worker VMs. It will also use local machine to generate all necessary TLS certificates and kubeconfigs for controller and worker components.

Above tools perform same steps as described in Kelsey's Hightower [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) tutorial.

## Prerequisites

* GCP access
* Terraform installed
* Ansible installed

## Running

**NOTE**: tested on amd64 Linux. Ansible tasks for client role downloads tool binaries for this OS and arch. All local files are stored under `~/.k8s-hard` directory.

```
git clone git@github.com:mikouaj/k8s-hard.git
cd k8s-hard
terraform apply
cd ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook site.yml -i inventory
```

## Verification

Once Ansible plays everything:

```
cd ~/.k8s-hard/bin
./kubectl get componentstatuses
```

```
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-1               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   

```

```
./kubectl get nodes
```

```
NAME          STATUS   ROLES    AGE   VERSION
k8s-worker1   Ready    <none>   48m   v1.18.6
k8s-worker2   Ready    <none>   48m   v1.18.6
k8s-worker3   Ready    <none>   48m   v1.18.6
```
