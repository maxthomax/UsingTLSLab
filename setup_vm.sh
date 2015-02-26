#! /bin/bash

# only needed in a configuration where the docker daemon runs in a NAT'ed VM, e.g. when running boot2docker on OSX

for i in {1..15}; do
	ii="0${i}";
	ii="${ii: -2}";
	#remove any old SSH port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_ssh${i}";
	#add new SSH port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_ssh$i,tcp,,22${ii},,22${ii}";
	#remove any old HTTP port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_http${i}";
	#add new HTTP port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_http${i},tcp,,80${ii},,80${ii}";
	#remove any old HTTPS port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 delete "containers_https${i}";
	#add new HTTPS port mapping
	VBoxManage modifyvm "boot2docker-vm" --natpf1 "containers_https${i},tcp,,443${ii},,443${ii}";
done
