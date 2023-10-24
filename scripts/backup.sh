#!/bin/bash

FILE=/home/ec2-user/orangehrm-aws/installed

if [ -f "$FILE" ]; then
	now=$(date +"%Y_%m_%d_%H_%M_%S")
    mkdir /home/ec2-user/.orangehrm-backups/$now
    docker exec ohrm-db sh -c 'exec mariadb-dump --all-databases -uroot -proot' > /home/ec2-user/.orangehrm-backups/$now/ohrm-db.sql
    docker cp -q ohrm:/var/www/html/lib/confs/Conf.php /home/ec2-user/.orangehrm-backups/$now/Conf.php
    cp /home/ec2-user/orangehrm-aws/compose.yml /home/ec2-user/.orangehrm-backups/$now/compose.yml
    echo "Backup created at /home/ec2-user/.orangehrm-backups/$now"
    unset now
else
    echo "OrangeHRM is not installed!"
fi
