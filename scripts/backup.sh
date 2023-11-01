#!/bin/bash

set -e

now=$(date +"%Y_%m_%d_%H_%M_%S")
backupDir="${OHRM_DIR}/backups/${now}"

echo -e "\nA backup of your database, configuration file and compose file will be created\n"
echo -e "${YELLOW}Creating Backup${ENDCOLOR}...................${WIP_ICON}"

mkdir -p "${backupDir}"
docker exec mariadb sh -c 'exec mariadb-dump --all-databases -uroot -proot' > "${backupDir}/mariadb.sql"
docker cp orangehrm:/var/www/html/lib/confs/Conf.php "${backupDir}/Conf.php" --quiet
docker cp orangehrm:/var/www/html/lib/confs/cryptokeys/key.ohrm "${backupDir}/key.ohrm" --quiet
cp "${OHRM_DIR}/compose.yml" "${backupDir}/compose.yml"

tput cuu1
echo -e "${GREEN}Creating Backup${ENDCOLOR}...................${SUCCESS_ICON}"
echo -e "Backup created at ${backupDir}\n"

exit 0
