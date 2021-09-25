#!/bin/bash
# This script have to be launched from proxmox server
# Download image
cd /var/tmp
wget https://cloud.debian.org/cdimage/cloud/OpenStack/current-10/debian-10-openstack-amd64.qcow2

# Create a VM
qm create 200 --name debian --memory 2048 --net0 virtio,bridge=vmbr0,firewall=1 --socket 2

# Import the disk in qcow2 format (as unused disk)
qm importdisk 200 debian-10-openstack-amd64.qcow2 local-lvm -format qcow2

# Attach disk
qm set 200 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-200-disk-0

# Setting boot and display settings with serial console
qm set 200 --ide2 local:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0

# We resize to 5G (initial image size was 2G)
qm resize 200 scsi0 +3G

# Ssh key for debian user (debian is the default user for openstack image)
qm set 200 --sshkey ~/.ssh/id_rsa.pub

# Check cloud-init config
qm cloudinit dump 200 user

# Make space
rm /var/tmp/debian-10-openstack-amd64.qcow2

