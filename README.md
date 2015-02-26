# UsingTLSLab

To use these containers, clone this repo and cd into it. In what follows, you may need to prefix the docker command with sudo depending on your platform.
If you are on OS X, it is assumed that boot2docker is installed. On Windows, a VM running docker is assumed.
On OS X, boot2docker needs to be started. This includes setting environment variables appropriately. Instructions are echoed on the command line.
If the image has not yet been built,
```
    ./build_image.sh
```
If you are running the docker daemon in a virtual machine, such as is the case with boot2docker/OSX, you need to bring the VM down, e.g.
```
    boot2docker down
```
so that its ports can be mapped correctly. On OS X this can be most easily achieved by executing the `setup_vm.sh` shell script. This script first removes existing mappings and then writes expected mappings. If the ports expected to be mapped are not mapped, there is an error message on the attempt to remove the mapping. This is OK.
The next step is to bring the docker daemon back up, i.e.
```
    boot2docker up
```
on OS X and start the containers with the correct port mapping. This can be done with the `start_containers.sh` script.
The containers are now reachable from external sources by specifying the IP address of the host and the port of the docker container, e.g.
```
    ssh root@10.0.132.191 -p 2211
```
or
```
    curl 10.0.132.191:8011
```
