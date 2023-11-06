#!/bin/bash

# This script will clone the AWS repository and create the login script

printf "\nWARNING: docker compose is not installed!\n"
printf "The user will not be able to continue with OrangeHRM installation\n"
printf "Refer: https://docs.docker.com/compose/install/linux/#install-the-plugin-manually\n\n"

# Check if git is installed
if ! [[ $(command -v git) ]]; then
    printf "\nGit is not installed!\n"
    printf "Try 'sudo dnf install git'\n\n"
    exit 1
fi

if [[ -d /home/ec2-user/.orangehrm ]]; then
    printf "The repository is already cloned!\n\n"
    exit 1
fi

git clone https://github.com/devishke-orange/orangehrm-aws --quiet /home/ec2-user/.orangehrm

# Check if docker & docker compose are installed
if ! [[ $(command -v docker) ]]; then
    printf "\nWARNING: docker is not installed!\n"
    printf "The user will not be able to continue with OrangeHRM installation\n"
    printf "Try 'sudo dnf install docker'\n\n"
elif docker compose version 2>&1 | grep -q "docker: 'compose' is not a docker command"; then
    printf "\nWARNING: docker compose is not installed!\n"
    printf "The user will not be able to continue with OrangeHRM installation\n"
    printf "Refer: https://docs.docker.com/compose/install/linux/#install-the-plugin-manually\n\n"
fi

if [[ -f /home/ec2-user/login_orangehrm.sh ]]; then
    rm -f /home/ec2-user/login_orangehrm.sh
fi

cp /home/ec2-user/.orangehrm/scripts/login_orangehrm /home/ec2-user/.orangehrm/login_orangehrm.sh

printf "The login script has been created at /home/ec2-user/.orangehrm/login_orangehrm.sh\n"
printf "Move it to /etc/profile.d using 'sudo mv /home/ec2-user/.orangehrm/login_orangehrm.sh /etc/profile.d/'\n\n"
