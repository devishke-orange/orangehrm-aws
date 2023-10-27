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
    cleanup
    exit 1
fi

git -C $OHRM_DIR fetch --quiet
newVersion=$(git -C .orangehrm/ diff main origin/main | grep "+    image: orangehrm/orangehrm")

if [[ -z $newVersion ]]; then
    echo -e "\nOrangeHRM is up to date!\n"
else
    echo "A new version of OrangeHRM is available!"
    echo "Please run '${GREEN}orangehrm upgrade{$ENDCOLOR}' to upgrade!"
fi

cleanup
exit 0;
