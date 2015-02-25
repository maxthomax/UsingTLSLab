#!/bin/bash

DIR="$(dirname "${0}")"

boot2docker start;

docker stop $(docker ps -a -q);
docker rm $(docker ps -a -q);

for i in {1..15};
	# Left-pad with zero to two digits and
	# call the container instantiating script.
	do 
		ii="0${i}";
		"${DIR}/run_one.sh" "${ii: -2}";
done
