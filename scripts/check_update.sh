#!/bin/bash

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/installed"
GREEN="\e[1;32m"
ENDCOLOR="\e[0m"

cleanup() {
    unset OHRM_DIR
    unset INSTALL_FILE
    unset newVersion
    unset GREEN
    unset ENDCOLOR
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
    echo -e "Please run '${GREEN}orangehrm upgrade{$ENDCOLOR}' to upgrade!"
fi

cleanup
exit 0;
