#!/bin/bash

# Set required variables
VERSION="v1.0"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"
LOG_FILE=/home/ec2-user/install_log.txt
BASHRC_FILE=/home/ec2-user/.bashrc
REPO_FOLDER=/home/ec2-user/.orangehrm
ORANGEHRM_ALIAS="alias orangehrm='sh /home/ec2-user/.orangehrm/scripts/orangehrm.sh'"
ORANGEHRM_ALIAS_COMMENT="# This alias is related to the orangehrm command"
WIP_ICON="🚧"
SUCCESS_ICON="✅"
ERROR_ICON="🔴"
now=$(date)

# Unset all variables and reset color
cleanup() {
    echo -e "${ENDCOLOR}"
    unset VERSION
    unset RED
    unset GREEN
    unset YELLOW
    unset ENDCOLOR
    unset LOG_FILE
    unset BASHRC_FILE
    unset REPO_FOLDER
    unset ORANGEHRM_ALIAS
    unset ORANGEHRM_ALIAS_COMMENT
    unset WIP_ICON
    unset SUCCESS_ICON
    unset ERROR_ICON
    unset now
}

# Write progress to log file
write_to_log() {
    now=$(date)
    if [[ $# -eq 1 ]]; then
        echo "[${now}] ${1}" >> $LOG_FILE
    fi
}

# Exiting before the installer has fully completed
early_exit() {
    write_to_log "Installer exited early"
    cleanup
    echo "Quitting installer.."
    sleep 1
    exit 0
}

# Exiting due to an error
err_exit () {
    write_to_log "Exited with error"
    cleanup
    exit 1
}

# Catch CTRL-C and run early_exit function
trap early_exit SIGINT

echo -e "\n${GREEN}OrangeHRM Command ${VERSION} Installer${ENDCOLOR}"
echo -e "This installer will install the ${GREEN}orangehrm${ENDCOLOR} command."
echo -e "The command will enable you to manage your AWS instance of OrangeHRM completely via the terminal\n"

# Check if the orangehrm command is already installed
if [[ -d "${REPO_FOLDER}/.git" ]]; then
    echo -e "OrangeHRM Command ${VERSION} is already installed!"
    echo -e "If you are trying to update the command please run ${GREEN}orangehrm update-command${ENDCOLOR}.\n"
    exit 1;
fi

echo -e "${YELLOW}Checking permissions${ENDCOLOR}..............${WIP_ICON}"
# Check if root or sudo
if ! [[ $(id -u) = 0 ]]; then
    tput cuu1
    echo -e "${RED}Checking permissions${ENDCOLOR}..............${ERROR_ICON}"
    # No logging since permissions may be insufficient
    echo -e "The script must be run as root or with sudo!"
    cleanup
    exit 1;
else
    write_to_log "Installer started"
    write_to_log "Script run as root"
    tput cuu1
    echo -e "${GREEN}Checking permissions${ENDCOLOR}..............${SUCCESS_ICON}"
fi

echo -e "${YELLOW}Checking pre-requisites${ENDCOLOR}...........${WIP_ICON}"
# Check if git is installed
if ! [[ $(command -v git) ]]; then
    tput cuu1
    echo -e "${RED}Checking pre-requisites${ENDCOLOR}...........${ERROR_ICON}"
    echo "git is not installed!"
    echo "Please install git and try running the script again"
    write_to_log "git not installed"
    err_exit
else
    tput cuu1
    echo -e "${GREEN}Checking pre-requisites${ENDCOLOR}...........${SUCCESS_ICON}"
    write_to_log "Pre-requisite check success"
fi

# Clone the repository
echo -e "${YELLOW}Cloning the repository${ENDCOLOR}............${WIP_ICON}"
if [[ -d $REPO_FOLDER ]]; then
    tput cuu1
    echo -e "${RED}Cloning the repository${ENDCOLOR}............${ERROR_ICON}"
    # TO-DO
    echo -e "The repository already exists. If you are trying to update the command please run ${GREEN}orangehrm update-command${ENDCOLOR}."
    write_to_log "Repo already exists"
    err_exit
else
    git clone --progress https://github.com/devishke-orange/orangehrm-aws $REPO_FOLDER &>/dev/null
    tput cuu1
    echo -e "${GREEN}Cloning the repository${ENDCOLOR}............${SUCCESS_ICON}"
    write_to_log "Repo successfully cloned"
fi

# Write the alias to .bashrc
echo -e "${YELLOW}Writing alias to .bashrc${ENDCOLOR}..........${WIP_ICON}"
if [[ $(grep "${ORANGEHRM_ALIAS}" < $BASHRC_FILE) ]]; then
    tput cuu1
    echo -e "${RED}Writing alias to .bashrc${ENDCOLOR}..........${ERROR_ICON}"
    echo "The alias is already written! Please remove any references to orangehrm from /home/ec2-user/.bashrc and restart the installer"
    write_to_log "Alias already written"
    grep orangehrm < $BASHRC_FILE >> $LOG_FILE
    err_exit
else
    echo -e "\n\n${ORANGEHRM_ALIAS_COMMENT}" >> $BASHRC_FILE
    echo -e "${ORANGEHRM_ALIAS}" >> $BASHRC_FILE
    tput cuu1
    echo -e "${GREEN}Writing alias to .bashrc${ENDCOLOR}..........${SUCCESS_ICON}"
    write_to_log "Alias written to .bashrc"
fi

# Copy the login-script to /etc/profile.d/
echo -e "${YELLOW}Creating login script${ENDCOLOR}.............${WIP_ICON}"
if [[ -f "/etc/profile.d/login_orangehrm.sh" ]]; then
    tput cuu1
    echo -e "${RED}Creating login script${ENDCOLOR}.............${ERROR_ICON}"
    echo "The login script already exists! Please check /etc/profile.d"
    write_to_log "Login script already exists in /etc/profile.d"
    err_exit
else
    cp "${REPO_FOLDER}/scripts/login_orangehrm.sh" /etc/profile.d/login_orangehrm.sh 2>>$LOG_FILE
    tput cuu1
    echo -e "${GREEN}Creating login script${ENDCOLOR}.............${SUCCESS_ICON}"
    write_to_log "Login script successfully moved to /etc/profile.d"
fi

echo -e "\nPlease run ${YELLOW}source /home/ec2-user/.bashrc${ENDCOLOR} to activate the ${GREEN}orangehrm${ENDCOLOR} command\n"

echo -e "Installation complete!\n"

write_to_log "Installer completed!"
cleanup
exit 0
