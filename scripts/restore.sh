#!/bin/bash

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/installed"
BACKUP_DIR="${OHRM_DIR}/backups"

cleanup() {
    unset OHRM_DIR
    unset INSTALL_FILE
    unset BACKUP_DIR
    unset backups
    unset backup
}


echo "Restore your OrangeHRM AWS Instance to a previous state"

if ! [[ -f $INSTALL_FILE ]]; then
    sh "${OHRM_DIR}/scripts/status.sh"
    exit 1
fi

echo "Please select a backup to restore from"
echo "The backups are named in a 'Year-Month-Date-Hour-Minute-Second' format"
echo -e "Select a backup by typing the corresponding number\n"
backups=("$(ls $BACKUP_DIR | sed 's/_/-/g')")
select backup in "${backups[@]}" "quit"
do
    if [[ $backup =~ "quit" ]]; then
        break;
    fi
    docker compose -f "${OHRM_DIR}/compose.yml" down
    cp "${BACKUP_DIR}/${backup}/compose.yml" /home/ec2-user/orangehrm-aws/compose.yml
    docker compose -f "${OHRM_DIR}/compose.yml" up -d --remove-orphans
    sleep 5
    docker cp -q "${BACKUP_DIR}/${backup}/Conf.php" ohrm:/var/www/html/lib/confs/Conf.php
    docker exec -i ohrm-db sh -c 'exec mariadb -uroot -proot' < "${BACKUP_DIR}/${backup}/ohrm-db.sql"
    break;
done

cleanup
exit 0
