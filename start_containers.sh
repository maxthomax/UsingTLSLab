#!/bin/bash

boot2docker start;

docker stop $(docker ps -a -q);
docker rm $(docker ps -a -q);

for i in {2..11}; 
	do docker run -d -p ${i}022:22 -p ${i}080:80 maxthomax/usingtlslab; 
done
