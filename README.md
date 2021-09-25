# The final technical goal of the project is to release a webapp, self hosted in a kube proxy.

I will build from ground up:

## Components
* Infrastructure
* proxmox for host creation
** hosts image : debian-10-openstack-amd64.qcow2

## Infrastructure software
* kubernetes
* weavework network
* metallb for service load balancing
* docker
* docker registry

## Application software
* django as based application
* sqllite3 for storage backend
* nfs for static file hosting
* nginx frontend
