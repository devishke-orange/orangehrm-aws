#!/bin/bash

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/installed"

cleanup() {
    unset OHRM_DIR
    unset INSTALL_FILE
    unset newVersion
}

if ! [[ -f $INSTALL_FILE ]]; then
    sh "${OHRM_DIR}/scripts/status.sh"
    exit 1
fi

git -C $OHRM_DIR fetch --quiet
newVersion=$(git -C $OHRM_DIR diff main origin/main)

if [[ -z $newVersion ]]; then
    echo "OrangeHRM is up to date!"
    exit 0;
fi
