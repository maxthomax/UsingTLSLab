#!/bin/bash

# Script for creating one container.

# Usage: run_one.sh ID
#   ID - two digits which will be used to distinguish this container from its peers

# Depends on: docker, (mkpasswd)


# Configuration

# Error exit code for wrong argument ID length
ERR_ARG_LEN=1

# Error exit code for non-numeric ID
ERR_ARG_NONNUMERIC=2

# Error exit code for ID already being used
ERR_ID_TAKEN=3

# Name of the image used in the lab
#LAB_IMAGE='secappdev/usingtls:latest'
LAB_IMAGE='secappdev/usingtls:latest'

# User name of the user
USER='student'

# What to call the containers except for the ID that will distinguish them
CONTAINTER_PREFIX='UsingTLS'


# Arguments processing

# The student's ID
ID="${1}"

# The directory where the configurations are stored, as an absolute path
pushd "`dirname ${0}`"
DIR="`pwd`"
popd

# The configuration directory of this ID
USER_DIR="${DIR}/students/${ID}"

# The README file of this ID
README="${USER_DIR}/README"

# The full name of this student's container
CONTAINER_NAME="${CONTAINTER_PREFIX}${ID}"

# Container ports and host ports
CONT_SSH_PORT='22'
HOST_SSH_PORT="22${ID}"
CONT_HTTP_PORT='80'
HOST_HTTP_PORT="80${ID}"
CONT_HTTPS_PORT='443'
HOST_HTTPS_PORT="443${ID}"


# Function library

# Displays usage instructions to stderr.
function show_usage() {
    cat <<-END_USAGE >&2
	Usage: run_one.sh ID
	    ID - two digits which will be used to distinguish this container from its peers
	END_USAGE
}

# Checks whether there already is a container with the desired name.
function id_taken() {
    NAME="${1}"

    # Calculate the offset of container names in the output of docker ps.
    HDR="$(docker ps --all=true | head -n 1)"
    HDR="${HDR%NAMES}"
    OFFSET="$(( ${#HDR} + 1 ))"

    # Look for the desired container name among the existing containers.
    docker ps --all=true \
    | cut -c "${OFFSET}-" \
    | grep --regexp="${CONTAINER_NAME}" --quiet

    # The exit code of the previous pipeline gives the answer.
    # The redundant 'return' below is just for readability.
    return $?
}

# Checks that the ID provided as argument to the script is as needed.
function check_id() {
    if [ "${ID}" == '--help' ]
    then
        # does the caller just want to see the usage?
        show_usage
        exit 0
    elif [ "${#ID}" -ne 2 ]
    then
        # isn't it two characters long?
        echo 'Error: Argument must be two characters long!' >&2
        show_usage
        exit "${ERR_ARG_LEN}"
    elif ! [ "${ID}" -eq "${ID}" ] 2> /dev/null
    then
        # Is the ID it made out of anything else than digits?
        # (Only numbers can return 0 when compared by -eq.
        # Non-numbers produce error code 2, the message is dumped.
        # In both cases the ! adapts the outcome to the logic here.)
        echo 'Error: Argument must consist of digits!' >&2
        show_usage
        exit "${ERR_ARG_NONNUMERIC}"
    elif id_taken "${CONTAINER_NAME}"
    then
        # Is the ID already taken?
        echo "Error: There already exists a container with ID '${CONTAINER_NAME}'!" >&2
        show_usage
        exit "${ERR_ID_TAKEN}"
    else
        return 0
    fi
}

# Echoes a randomly chosen character from a string.
function echo_random() {
    S="${1}"
    RANDOM_INDEX=$(( ${RANDOM} % ${#S} ))
    echo -n "${S:${RANDOM_INDEX}:1}"
}

# Creates login credentials for accessing the container and
# prepares an entry for the /etc/shadow file.
# E.g.:
#student:$6$sdyDx7EX$Mh3yhc5GA5fcZTGhL0n53s7drigqFnVniptlB5Dyz7s8mo.VFvulYvIKaQLhHMyeoNO.RLflcTJqUrhn83dfP.:16486:0:99999:7:::
#student:$6$bzQlQubP$3OIOvMnN.nrU23vRx1z11wqr7i90xFT0qvuT9OPRNBw3GfdkF1XLczsUP7ROvWnxP5gBZOA.D.C2WkLear8mh1:
function create_credentials() {
    PID="${1}"

    # Construct password
    # The dictionaries omit letters that resemble others too much.
    # As the distinction is used just for generating pronounceable passwords,
    # vowels and consonants are not strictly the correct grammatical sets.
    DICT_LOWER_VOWELS='aeiouy'
    DICT_LOWER_CNSNTS='bcdfghjkmnpqrstvwxz'  # omitted: l
    DICT_UPPER_VOWELS='AEUY'    # omitted: I, O
    DICT_UPPER_CNSNTS='BCDFGHJKLMNPQRSTVWXZ'
    PWD="$(
        echo -n ${PID}
        echo_random "${DICT_UPPER_CNSNTS}"
        echo_random "${DICT_UPPER_VOWELS}"
        echo_random "${DICT_LOWER_CNSNTS}"
        echo_random "${DICT_LOWER_VOWELS}"
    )"
    # Compute the password's hash
    PWD_HASH="$(echo "${PWD}" | mkpasswd --stdin --method=sha-512)"

    # Compute the timestamp of the password's creation
    DATE_LAST_CHANGE=$(( $(date "+%s") / 24 / 60 / 60 ))

    # Save shadow file entry
    echo "${USER}:${PWD_HASH}:${DATE_LAST_CHANGE}:0:99999:7:::" >> "${USER_DIR}/etc/shadow"

    # Save credentials to the user's README
    echo "Username: ${USER}" >> "${README}"
    echo "Password: ${PWD}"  >> "${README}"
}

# Launches a new container.
function run_container() {
    PID="${1}"

    # Create copies of directories needed by students
    mkdir -p "${USER_DIR}"
    cp -a "${DIR}/www_skel/" "${USER_DIR}/www"

    # The following commands are temporarily suspended, as on Mac OSX
    # the dependency on 'mkpasswd' is not easily satisfied.
    # Instead, all containers are to be accessed as Root, with a shared
    # password, handled in Dockerfile.
    #cp -a "${DIR}/etc_skel/" "${USER_DIR}/etc"
    # Create login credentials
    #create_credentials "${ID}"

    # Save daemon ports to the user's README
    echo "SSH   port:  ${HOST_SSH_PORT}"  >> "${README}"
    echo "HTTP  port:  ${HOST_HTTP_PORT}" >> "${README}"
    echo "HTTPS port: ${HOST_HTTPS_PORT}" >> "${README}"

#return
    # Run interactively or headless?
    #MODE="--interactive=true --tty=true"
    MODE="--detach=true"

    # Launch the container
    docker run \
        ${MODE} \
        --volume="${USER_DIR}/www:/var/www" \
        --publish "${HOST_SSH_PORT}:${CONT_SSH_PORT}" \
        --publish "${HOST_HTTP_PORT}:${CONT_HTTP_PORT}" \
        --publish "${HOST_HTTPS_PORT}:${CONT_HTTPS_PORT}" \
        --name="${CONTAINER_NAME}" \
        "${LAB_IMAGE}"

    # Temporarily suspended separate credentials per container.
    #   --volume="${USER_DIR}/etc/shadow:/etc/shadow" \
}

# Destroys ID's container and configuration
function destroy_ID() {
    # Gracefully stop container
    docker stop "${CONTAINER_NAME}"

    # Remove container
    docker rm "${CONTAINER_NAME}"

    # Remove external configuration
    rm -r "${USER_DIR}"
}


# Main program

function main() {
    # Validate input (and abort if input is invalid)
    check_id "${ID}"

    # Start the container
    run_container "${ID}"
}

# Call main program with the arguments.
main "${@}"

#EOF
