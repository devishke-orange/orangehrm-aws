#!/bin/bash

OHRM_DIR=/home/ec2-user/.orangehrm
INSTALL_FILE="${OHRM_DIR}/installed"
newVersion=""
answer=""
YES_REGEX="^y(e|es)?$"
NO_REGEX="^n(o)?$"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"
WIP_ICON="🚧"
SUCCESS_ICON="✅"

cleanup() {
    unset OHRM_DIR
    unset INSTALL_FILE
    unset newVersion
    unset answer
    unset YES_REGEX
    unset NO_REGEX
    unset GREEN
    unset YELLOW
    unset ENDCOLOR
    unset WIP_ICON
    unset SUCCESS_ICON
}

yes_no_check() {
	while ! [[ $answer =~ $YES_REGEX|$NO_REGEX ]]; do
		echo "Please enter yes or no"
		read -rp "> " answer
	done
}

if ! [[ -f $INSTALL_FILE ]]; then
    sh "${OHRM_DIR}/scripts/status.sh"
    exit 1
fi

git -C $OHRM_DIR fetch --quiet
newVersion=$(git -C $OHRM_DIR diff main origin/main)

if [[ -z $newVersion ]]; then
    echo -e "${GREEN}OrangeHRM is up to date!${ENDCOLOR}"
    exit 0;
fi

echo -e "${YELLOW}A new version of OrangeHRM is available${ENDCOLOR}"

echo -e "Are you sure you want to upgrade? ${YELLOW}[yes/no]${ENDCOLOR}"
read -rp "> " answer
yes_no_check
if [[ $answer =~ $NO_REGEX ]]; then
    echo "Quitting upgrader"
    exit 0
fi

sh "${OHRM_DIR}/scripts/backup.sh"

echo -e "${YELLOW}Stopping OHRM container${ENDCOLOR}...........${WIP_ICON}"
docker stop ohrm &>/dev/null
docker rm ohrm &>/dev/null
docker system prune -af &>/dev/null
tput cuu1
echo -e "${GREEN}Stopping OHRM container${ENDCOLOR}...........${SUCCESS_ICON}"

echo -e "${YELLOW}Pulling new compose file${ENDCOLOR}..........${WIP_ICON}"
git -C $OHRM_DIR pull --quiet
tput cuu1
echo -e "${GREEN}Pulling new compose file${ENDCOLOR}..........${SUCCESS_ICON}"

echo -e "${YELLOW}Upping the container${ENDCOLOR}..............${WIP_ICON}"
docker compose -f "${OHRM_DIR}/compose.yml" up -d --remove-orphans &>/dev/null
sleep 5
tput cuu1
echo -e "${GREEN}Upping the container${ENDCOLOR}..............${SUCCESS_ICON}"

echo -e "${YELLOW}Upgrading OrangeHRM!${ENDCOLOR}..............${WIP_ICON}"
docker exec ohrm php installer/console upgrade:run --dbHost mariadb1011 --dbPort 3306 --dbName orangehrm --dbUser root --dbUserPassword root &>/dev/null
tput cuu1
echo -e "${GREEN}Upgrading OrangeHRM!${ENDCOLOR}..............${SUCCESS_ICON}"

echo -e "${GREEN}\nOrangeHRM was successfully upgraded!${ENDCOLOR}\n"

cleanup
exit 0
