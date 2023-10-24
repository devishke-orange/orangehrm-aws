#!/bin/bash

FILE=/home/ec2-user/orangehrm-aws/compose.yml

if [[ -f "$FILE" ]]
then
    backups=( /"home"/"ec2-user"/".orangehrm-backups"/* )
    select backup in "${backups[@]}" "quit"
    do
        if [[ $backup == "quit" ]]
        then
            break;
        else
            docker exec ohrm-db mariadb -proot -e "drop database if exists orangehrm"
            docker compose -f /home/ec2-user/orangehrm-aws/compose.yml down
            docker system prune -af
            cp $backup/compose.yml /home/ec2-user/orangehrm-aws/compose.yml
            docker compose -f /home/ec2-user/orangehrm-aws/compose.yml up -d --remove-orphans
            sleep 5
            docker cp -q $backup/Conf.php ohrm:/var/www/html/lib/confs/Conf.php
            docker exec -i ohrm-db sh -c 'exec mariadb -uroot -proot' < $backup/ohrm-db.sql
            break;
        fi
    done
else
    echo "OrangeHRM is not installed!"
fi
