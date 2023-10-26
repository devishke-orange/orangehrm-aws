#!/bin/bash

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/installed"
BACKUP_DIR="${OHRM_DIR}/backups"
NOW=$(date +"%Y_%m_%d_%H_%M_%S")
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"

cleanup() {
    unset OHRM_DIR
    unset INSTALL_FILE
    unset BACKUP_DIR
    unset NOW
}

if ! [[ -f $INSTALL_FILE ]]; then
    sh "${OHRM_DIR}/scripts/status.sh"
    exit 1
fi

echo -e "\nA backup of your database, configuration file and compose file will be created\n"
echo -e "${YELLOW}Creating Backup${ENDCOLOR}...................🚧"
mkdir -p "/home/ec2-user/.orangehrm/backups/${NOW}"
docker exec ohrm-db sh -c 'exec mariadb-dump --all-databases -uroot -proot' > "${BACKUP_DIR}/${NOW}/ohrm-db.sql"
docker cp -q ohrm:/var/www/html/lib/confs/Conf.php "${BACKUP_DIR}/${NOW}/Conf.php"
cp "${OHRM_DIR}/compose.yml" "${BACKUP_DIR}/${NOW}/compose.yml"
tput cuu1
echo -e "${GREEN}Creating Backup${ENDCOLOR}...................✅"
echo -e "Backup created at ${BACKUP_DIR}/${NOW}\n"

cleanup
exit 0
