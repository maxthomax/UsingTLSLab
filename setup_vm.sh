#! /bin/bash

# only needed in a configuration where the docker daemon runs in a NAT'ed VM, e.g. when running boot2docker on OSX

for i in {2..11}; do
	#remove any old SSH port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_ssh${i}";
	#add new SSH port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_ssh$i,tcp,,22${i},,22${i}";
	#remove any old HTTP port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_http${i}";
	#add new HTTP port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_http${i},tcp,,80${i},,80${i}";
	#remove any old HTTPS port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_https${i}";
	#add new HTTPS port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_https${i},tcp,,443${i},,443${i}";
done
