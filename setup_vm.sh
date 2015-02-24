#! /bin/bash

# only needed in a configuration where the docker daemon runs in a NAT'ed VM, e.g. when running boot2docker on OSX

for i in {2..11}; do 
	#remove old SSH port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_ssh${i}";
	#add new SSH port mapping	
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_ssh$i,tcp,,${i}022,,${i}022"; 
	#remove old HTTP port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_http${i}";
	#add new HTTP port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_http${i},tcp,,${i}080,,${i}080"; 
done
