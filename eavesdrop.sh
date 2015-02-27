#!/bin/bash

FILE_PREFIX='http_request_'

OUT_DIR="$(mktemp --directory)"

if [ $(id --user) -ne 0 ]
then
    echo 'Script needs to be run as root. Exiting...' >&2
    exit 1
fi

IP_ADDR="$(
    ifconfig eth0 \
    | grep "inet addr" \
    | sed -e 's/.*inet addr:\(.*\)  Bcast.*/\1/g'
)"

# Signal handler for SIGINT (Ctrl+c)
function cancel() {
    # Wait for tcpflow to finish in the background.
    wait
    # Clean up the output directory.
    rm -r "${OUT_DIR}"
    # Announce stop.
    echo 'Stopped'
    # Exit with success code.
    exit 0
}

# Announce start and keyboard shortcut for stopping.
echo 'Extracting passwords from the HTTP requests... (Press Ctrl+c to stop).'

# Launch the underlying eavesdropper in the background.
tcpflow -i eth0 -o "${OUT_DIR}" -T "${FILE_PREFIX}%N" "dst ${IP_ADDR}" &

# Install the signal handler which will stop the next infinite loop.
trap 'cancel' SIGINT

# Ensure that path wildcards that don't match anything expand to null.
shopt -s nullglob

# Infinite loop
while /bin/true
do
    # In each iteration, process all currently available TCP flows
    for F in "${OUT_DIR}/${FILE_PREFIX}"*
    do
        # If they TCP flow contains a login form submission...
        if grep -q "^username=" "${F}"
        then
            # ... brag about the data that was found.
            # The Host header is included, too, so each participant can
            # recognise his or her own request.
            # The search patterns are highlighted in the output.
            # Since the patterns are defined to be all the non-custom text,
            # the user-submitted values stand out by not being highlighted.
            grep --colour=auto "^Host: \|^username=\|&password=" "${F}"
        fi
        # Remove the TCP flow file, so it is not processed
        # in the next iterations of the outer loop.
        rm "${F}"

        # Wait between files, in order not to overload the system.
        sleep 1
    done
done

#EOF
