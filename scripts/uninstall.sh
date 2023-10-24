#!/bin/bash
# REMOVE

FILE=/home/ec2-user/orangehrm-aws/compose.yml

if [[ -f "$FILE" ]]
then
    docker exec ohrm-db mariadb -proot -e "drop database if exists orangehrm"
    docker compose -f /home/ec2-user/orangehrm-aws/compose.yml down
    docker system prune -af
    sudo rm -r /home/ec2-user/orangehrm-aws
else
    echo "OrangeHRM is not installed!"
fi
