#!/bin/bash
# TO-DO: REMOVE

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/installed"

if ! [[ -f $INSTALL_FILE ]]; then
    sh "${OHRM_DIR}/scripts/status.sh"
    exit 1
fi

docker exec ohrm-db mariadb -proot -e "drop database if exists orangehrm"
docker compose -f "${OHRM_DIR}/compose.yml" down
docker system prune -af
rm -f "${OHRM_DIR}/installed"
rm -rf "${OHRM_DIR}/backups/*"

unset OHRM_DIR
unset INSTALL_FILE

exit 0
