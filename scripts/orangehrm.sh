#!/bin/bash

function help() {
    echo "Usage: orangehrm COMMAND"
    echo "Commands:"
    echo "  status      check whether the system is installed or not"
    echo "  install     installs the system"
    echo "  upgrade     upgrade the system"
    echo "  backup      backup the system"
    echo "  restore     restore a backup"
}

if [[ $# -eq 0 ]]
then
    help
elif [[ $1 = "install" ]]
then
    sh /home/ec2-user/.orangehrm/scripts/install.sh
elif [[ $1 = "upgrade" ]]
then
    sh /home/ec2-user/.orangehrm/scripts/upgrade.sh
elif [[ $1 = "backup" ]]
then
    sh /home/ec2-user/.orangehrm/scripts/backup.sh
elif [[ $1 = "restore" ]]
then
    sh /home/ec2-user/.orangehrm/scripts/restore.sh
elif [[ $1 = "uninstall" ]]
then
    sh /home/ec2-user/.orangehrm/scripts/uninstall.sh
elif [[ $1 = "status" ]]
then
    sh /home/ec2-user/.orangehrm/scripts/status.sh
else
    help
fi
