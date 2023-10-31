#!/bin/bash

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/.installed"
COMPOSE_FILE="${OHRM_DIR}/compose.yml"
GREEN="\e[1;32m"
ENDCOLOR="\e[0m"
currentVersion=""
newVersion=""

check_installed() {
    if ! [[ -f $INSTALL_FILE ]]; then
        sh "${OHRM_DIR}/scripts/status.sh"
        cleanup
        exit 1
    fi
}

get_versions() {
    currentVersion=$(grep "    image: orangehrm/orangehrm:" ${COMPOSE_FILE} | sed 's/    image: orangehrm\/orangehrm://')
    newVersion=$(curl --silent https://raw.githubusercontent.com/devishke-orange/orangehrm-aws/main/compose.yml | grep "    image: orangehrm/orangehrm:" | sed 's/    image: orangehrm\/orangehrm://')
}

check_update() {
    if [[ "${currentVersion}" = "${newVersion}" ]]; then
        echo -e "\nOrangeHRM is up to date!\n"
    else
        echo -e "\nA new version of OrangeHRM is available!"
        echo -e "Please run '${GREEN}orangehrm upgrade${ENDCOLOR}' to upgrade!\n"
    fi
}

cleanup() {
    unset INSTALL_FILE
    unset GREEN
    unset ENDCOLOR
    unset currentVersion
    unset newVersion
    unset get_versions
    unset check_update
}

check_installed
get_versions
check_update

cleanup
unset cleanup
exit 0;
