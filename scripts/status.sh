#!/bin/bash

# Set required variables
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"

# Unset all variables
cleanup() {
    unset GREEN
    unset YELLOW
    unset ENDCOLOR
}

if [[ -z "/home/ec2-user/orangehrm-aws/installed" ]]
then
    # TO-DO add version
    echo -e "\n${GREEN}OrangeHRM is installed!${ENDCOLOR}\n"
    cleanup
else
    echo -e "\n${YELLOW}OrangeHRM is not installed!${ENDCOLOR}"
    echo -e "Run ${GREEN}orangehrm install${ENDCOLOR} to start the installation\n"
    cleanup
fi
