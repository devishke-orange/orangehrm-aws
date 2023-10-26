#!/bin/bash

SCRIPT_DIR=/home/ec2-user/.orangehrm/scripts
HELP_FILE=/home/ec2-user/.orangehrm/assets/HELP

function help() {
    cat $HELP_FILE
}

# Give the name of the script as the argument
ohrm_script() {
    sh "${SCRIPT_DIR}/${1}"
}

if [[ $# -eq 0 ]]; then
    # If no arguments
    help
elif [[ $1 = "install" ]]; then
    ohrm_script install_orangehrm.sh
elif [[ $1 = "upgrade" ]]; then
    ohrm_script upgrade.sh
elif [[ $1 = "backup" ]]; then
    ohrm_script backup.sh
elif [[ $1 = "restore" ]]; then
    ohrm_script restore.sh
elif [[ $1 = "uninstall" ]]; then
    # TO-DO: remove?
    ohrm_script uninstall.sh
elif [[ $1 = "status" ]]; then
    ohrm_script status.sh
elif [[ $1 = "create-login-message" ]]; then
    ohrm_script create_login_message.sh
elif [[ $1 = "check-update" ]]; then
    ohrm_script check_update.sh
elif [[ $1 = "help" ]]; then
    help
else
    echo -e "\n${1} is not an orangehrm command"
    echo -e "See 'orangehrm help'\n"
fi

unset SCRIPT_DIR
unset HELP_FILE

exit 0;
