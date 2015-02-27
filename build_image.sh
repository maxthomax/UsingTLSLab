#!/bin/bash

# Locate the directory containing this script.
DIR="$(dirname "${0}")"

# Fixed parts of the image name
IMG_USER=secappdev
IMG_NAME=usingtls

# Versioning tag (and history in the comments)
# v01: Customised MAINTAINER, Installed extra editors, copied supervisord.conf.
# v02: Additionally exposed SSH. HTTP and HTTPS ports, included supervisord as default command.
# v03: Explicitly specified supervisord configuration file to get rid of a warning.
# v04: Added regular user creation to the initialisation, but with wrong syntax.
# v05: Fixed syntax of regular user creation.
# v06: Changed supervisord.conf to initialise the password of the regular user.
# v07: Reverted to original supervisord.conf, as password is provisioned in a simpler way.
# v08: Added PHP5 to the installed software.
# v09: Reverted from distinct passwords per container to a shared password and root access.
# v10: Added Certification Authority simulation scripts
IMG_TAG=v10

# Assemble full image name.
IMAGE_TAG="${IMG_USER}/${IMG_NAME}:${IMG_TAG}"

LOGFILE="${DIR}/logs/docker_build_output_${IMG_TAG}.log"

# Ensure that the version has been updated and documented.
if [ -e "${LOGFILE}" ]
then
    echo "It looks like the version tag in the build script has not been updated." >&2
    echo "Please update IMG_TAG in this script and document the new version." >&2
    echo "Aborting." >&2

    exit 1
fi

# Ensure there is a directory for logs.
mkdir -p "${DIR}/logs"

# Build the image.
pushd "${DIR}" > /dev/null
docker build --tag="${IMAGE_TAG}" . | tee "${LOGFILE}"
popd > /dev/null

# Add "latest" tag to the new image.
docker tag "${IMAGE_TAG}" "${IMG_USER}/${IMG_NAME}:latest"

#EOF
