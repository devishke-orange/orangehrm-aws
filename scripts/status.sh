#!/bin/bash

# Set required variables
INSTALL_FILE="/home/ec2-user/.orangehrm/installed"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"

# Unset all variables
cleanup() {
    unset INSTALL_FILE
    unset GREEN
    unset YELLOW
    unset ENDCOLOR
}

if [[ -f $INSTALL_FILE ]]
then
    # TO-DO add version
    echo -e "\n${GREEN}OrangeHRM is installed!${ENDCOLOR}\n"
    cleanup
else
    echo -e "\n${YELLOW}OrangeHRM is not installed!${ENDCOLOR}"
    echo -e "Run ${GREEN}orangehrm install${ENDCOLOR} to start the installation\n"
    cleanup
fi
