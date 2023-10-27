#!/bin/bash

FILE=/home/ec2-user/.orangehrm/installed

firstName=""
lastName=""
email=""
username=""
password=""
password2=""
orgName=""
answer="no"
encryptOption=""
token=""
ohrmIP=""
FIELDS=("First Name" "Last Name" "Work Email" "Org Name" "Country" "Username" "Password" "Data Encryption")
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"
WIP_ICON="🚧"
SUCCESS_ICON="✅"
ERROR_ICON="🔴"
YES_REGEX="^y(e|es)?$"
NO_REGEX="^n(o)?$"

cleanup () {
	unset firstName
	unset lastName
	unset email
	unset username
	unset password
	unset password2
	unset orgName
	unset answer
	unset encryptOption
	unset token
	unset ohrmIP
	unset FIELDS
	unset RED
	unset GREEN
	unset YELLOW
	unset ENDCOLOR
	unset WIP_ICON
	unset SUCCESS_ICON
	unset ERROR_ICON
	unset YES_REGEX
	unset NO_REGEX
}

check_prereq () {
	echo -e "${YELLOW}Checking pre-requisites${ENDCOLOR}...........${WIP_ICON}"

	# Check if docker is installed
	if ! [[ $(command -v docker) ]]; then
		tput cuu1
		echo -e "${RED}Checking pre-requisites${ENDCOLOR}...........${ERROR_ICON}"
		echo -e "Docker is not installed! Please re-install docker and try again"
		exit 1
	fi

	# Check if the docker service is active
	if [[ $(sudo systemctl is-active docker) = "inactive" ]]
	then
		tput cuu1
		echo -e "${RED}Checking pre-requisites${ENDCOLOR}...........${ERROR_ICON}"
		echo -e "Docker is not active!"
		echo -e "Please activate docker using 'sudo systemctl start docker' and retry the installation"
		echo -e "If you want docker to start on boot you can run 'sudo systemctl enable docker' as well"
		exit 1
	fi

	# Check if docker compose is installed
	if docker compose version 2>&1 | grep -q "docker: 'compose' is not a docker command"; then
		tput cuu1
		echo -e "${RED}Checking pre-requisites${ENDCOLOR}...........${ERROR_ICON}"
		echo -e "Docker Compose is not installed! Please install docker compose and try again!"
		exit 1
	fi

	tput cuu1
	echo -e "${GREEN}Checking pre-requisites${ENDCOLOR}...........${SUCCESS_ICON}\n"
}

early_exit () {
	echo -e "\n${RED}Quitting the installation..${ENDCOLOR}"
	echo -e "${YELLOW}Cleaning install files${ENDCOLOR}............${WIP_ICON}"

	# Boolean to determine whether to run docker prune or not
	containersActive=false

	# Check if OrangeHRM container is running
	if [[ $(docker inspect -f '{{.State.Running}}' ohrm 2>/dev/null) = "true" ]]
	then
		# Silently stop and remove the OrangeHRM container
		docker stop ohrm &>/dev/null
		docker rm ohrm &>/dev/null
		containersActive=true
	fi

	# Check if MariaDB container is running
	if [[ $(docker inspect -f '{{.State.Running}}' ohrm-db 2>/dev/null) = "true" ]]
	then
		# Silently drop the orangehrm database
		docker exec ohrm-db mariadb -proot -e "drop database if exists orangehrm" &> /dev/null
		# Silently stop and remove the MariaDB container
		docker stop ohrm-db &>/dev/null
		docker rm ohrm-db &>/dev/null
		containersActive=true
	fi
	
	if [[ $containersActive ]]
	then
		# Remove network and reclaim space taken by containers
    	docker system prune -af &> /dev/null
	fi

	# Check if the repository has been cloned
	if [[ -d "/home/ec2-user/orangehrm-aws" ]]
	then
		# Silently remove the repository
    	sudo rm -r /home/ec2-user/orangehrm-aws &> /dev/null
	fi
	
	tput cuu1
	echo -e "${GREEN}Cleaning install files${ENDCOLOR}............${SUCCESS_ICON}"
	echo -e "You can run \"${GREEN}orangehrm install${ENDCOLOR}\" to restart the installation${ENDCOLOR}"
	cleanup
	exit 0
}

yes_no_check() {
	while ! [[ $answer =~ $YES_REGEX|$NO_REGEX ]]; do
		echo "Please enter yes or no"
		read -rp "> " answer
	done
}

reset_answer() {
	answer="no"
}

show_start_message() {
	cat /home/ec2-user/.orangehrm/assets/LOGO
	echo -e "\n${GREEN}Starting the OrangeHRM Installation${ENDCOLOR}\n"
}

get_license_agreement() {
	echo -ne "Please read and agree to the following license ${YELLOW}[press enter]${ENDCOLOR}"
	read -r
	tput cuu1
	tput el
	less -P "Press ENTER to read more, press q to quit" /home/ec2-user/.orangehrm/assets/LICENSE
	echo -e "Do you agree to the license? ${YELLOW}[yes/no]${ENDCOLOR}"
	read -rp "> " answer
	yes_no_check
	if [[ $answer =~ $NO_REGEX ]]
	then
		early_exit
	fi
	reset_answer
}

get_first_name() {
	echo -e "Enter the admin employee's first name ${YELLOW}[required]${ENDCOLOR}"
	read -rp "> " firstName
	while [[ -z "$firstName" ]]
	do
		echo -e "${RED}The first name cannot be empty!${ENDCOLOR}"
		echo -e "Enter the admin employee's first name ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " firstName
	done
}

get_last_name() {
	echo -e "Enter the admin employee's last name ${YELLOW}[required]${ENDCOLOR}"
	read -rp "> " lastName
	while [[ -z "$lastName" ]]
	do
		echo -e "${RED}The last name cannot be empty!${ENDCOLOR}"
		echo -e "Enter the admin employee's last name ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " lastName
	done
}

get_email() {
	echo -e "Enter the admin employee's email ${YELLOW}[required]${ENDCOLOR}"
	read -rp "> " email
	while [[ -z "$email" ]]
	do
		echo -e "${RED}The email cannot be empty!${ENDCOLOR}"
		echo -e "Enter the admin employee's email ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " email
	done
}

get_org_name() {
	echo -e "Enter the name of your organization ${YELLOW}[required]${ENDCOLOR}"
	read -rp "> " orgName
	while [[ -z "$orgName" ]]
	do
		echo -e "${RED}The organisation name cannot be empty!${ENDCOLOR}"
		echo -e "Enter the name of your organization ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " orgName
	done
}

get_country_code() {
	echo -e "Select your country code ${YELLOW}[type the number]${ENDCOLOR}"
	select country in $(tr '\n' ' ' < /home/ec2-user/.orangehrm/assets/COUNTRIES)
	do 
		if [[ -z "$country" ]]
		then
			echo -e "${RED}Please select a country${ENDCOLOR}"
		else
			break
		fi
	done
}

get_username() {
	echo -e "Enter the admin username ${YELLOW}[required]${ENDCOLOR}"
	read -rp "> " username
	while [[ -z "$username" ]]
	do
		echo -e "${RED}The username cannot be empty!${ENDCOLOR}"
		echo -e "Enter the admin username ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " username
	done
}

get_password() {
	echo -e "Enter the admin password ${YELLOW}[hidden]${ENDCOLOR}"
	read -s -rp "> " password
	while [[ -z "$password" ]]
	do
		echo -e "\n${RED}The password cannot be empty!${ENDCOLOR}"
		echo -e "Enter the admin password ${YELLOW}[hidden]${ENDCOLOR}"
		read -s -rp "> " password
	done
	echo -e "\nRe-enter the admin password ${YELLOW}[hidden]${ENDCOLOR}"
	read -s -rp "> " password2
	while [[ "$password" != "$password2" ]]
	do
		echo -e "\n${RED}The passwords were not the same!${ENDCOLOR}"
		echo -e "Enter the admin password ${YELLOW}[hidden]${ENDCOLOR}"
		read -s -rp "> " password
		while [[ -z "$password" ]]
		do
			echo -e "\n${RED}The password cannot be empty!${ENDCOLOR}"
			echo -e "Enter the admin password ${YELLOW}[hidden]${ENDCOLOR}"
			read -s -rp "> " password
		done
		echo -e "\nRe-enter the admin password ${YELLOW}[hidden]${ENDCOLOR}"
		read -s -rp "> " password2
	done
}

get_encrypt() {
	echo -e "\nDo you want to enable data encryption? ${YELLOW}[yes/no]${ENDCOLOR}"
	read -rp "> " answer
	yes_no_check
	if [[ $answer =~ $YES_REGEX ]]
	then
		encryptOption="y"
	else
		encryptOption="n"
	fi
	reset_answer
}

show_config() {
	echo "==============================="
	echo -e "${GREEN}First Name${ENDCOLOR}: 	    $firstName"
	echo -e "${GREEN}Last Name${ENDCOLOR}: 	    $lastName"
	echo -e "${GREEN}Work Email${ENDCOLOR}: 	    $email"
	echo -e "${GREEN}Org Name${ENDCOLOR}: 	    $orgName"
	echo -e "${GREEN}Country${ENDCOLOR}:	    $country"
	echo -e "${GREEN}Username${ENDCOLOR}: 	    $username"
	echo -e "${GREEN}Data Encryption${ENDCOLOR}:    $encryptOption"
	echo "==============================="
}

get_config_values() {
	get_first_name
	get_last_name
	get_email
	get_org_name
	get_country_code
	get_username
	get_password
	get_encrypt

	echo -e "\nPlease confirm the following"
	show_config
	echo -e "\nAre these details correct? ${YELLOW}[yes/no]${ENDCOLOR}"
	read -rp "> " answer
	yes_no_check
	if [[ $answer =~ $NO_REGEX ]]; then
		echo -e "\nPlease choose a field to edit (or select quit)"
		select field in "${FIELDS[@]}" "quit"; do
			if [[ $field = "quit" ]]; then
				break;
			elif [[ $field = "First Name" ]]; then
				echo "Current Value: ${firstName}"
				get_first_name
			elif [[ $field = "Last Name" ]]; then
				echo "Current Value: ${lastName}"
				get_last_name
			elif [[ $field = "Work Email" ]]; then
				echo "Current Value: ${email}"
				get_email
			elif [[ $field = "Org Name" ]]; then
				echo "Current Value: ${orgName}"
				get_org_name
			elif [[ $field = "Country" ]]; then
				echo "Current Value: ${country}"
				get_country_code
			elif [[ $field = "Username" ]]; then
				echo "Current Value: ${username}"
				get_username
			elif [[ $field = "Password" ]]; then
				get_password
			elif [[ $field = "Data Encryption" ]]; then
				get_encrypt
			else
				echo "Invalid option"
			fi
			show_config
		done
	fi
}

create_containers() {
	echo -e "\n${YELLOW}Creating the containers${ENDCOLOR}...........${WIP_ICON}"
	docker compose -f /home/ec2-user/.orangehrm/compose.yml up -d --remove-orphans &> /dev/null
	tput cuu1
	sleep 5
	echo -e "${GREEN}Creating the containers${ENDCOLOR}...........${SUCCESS_ICON}"
}

update_configuration() {
	echo -e "${YELLOW}Updating install configuration${ENDCOLOR}....${WIP_ICON}"
	docker exec ohrm sed -i 's/hostName: 127.0.0.1/hostName: mariadb1011/' installer/cli_install_config.yaml
	docker exec ohrm sed -i 's/databaseName: orangehrm_mysql/databaseName: orangehrm/' installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/adminEmployeeFirstName: OrangeHRM/adminEmployeeFirstName: $firstName/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/adminEmployeeLastName: Admin/adminEmployeeLastName: $lastName/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/adminUserName: Admin/adminUserName: $username/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/adminPassword: Ohrm@1423/adminPassword: $password/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/workEmail: admin@example.com/workEmail: $email/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/ name: OrangeHRM/ name: $orgName/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/country: US/country: $country/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/enableDataEncryption: n/enableDataEncryption: $encryptOption/" installer/cli_install_config.yaml
	docker exec ohrm sed -i "s/registrationConsent: true/registrationConsent: false/" installer/cli_install_config.yaml
	tput cuu1
	echo -e "${GREEN}Updating install configuration${ENDCOLOR}....${SUCCESS_ICON}"
}

install_orangehrm() {
	echo -e "${YELLOW}Installing OrangeHRM${ENDCOLOR}..............${WIP_ICON}"
	docker exec ohrm php installer/cli_install.php &> /dev/null
	tput cuu1
	echo -e "${GREEN}Installing OrangeHRM${ENDCOLOR}..............${SUCCESS_ICON}"
}

write_install_file() {
	printf "DO NOT DELETE THIS FILE!
This file let's the instance know that OrangeHRM is installed!
If you delete this file, the instance will run an install script the next time you SSH into this instance." > $FILE
	echo -e "\n${GREEN}OrangeHRM is finished installing!${ENDCOLOR}"
}

print_aws_ip() {
	token=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
	ohrmIP=$(curl -s -H "X-aws-ec2-metadata-token: ${token}" http://169.254.169.254/latest/meta-data/public-ipv4)
	echo -e "\nVisit ${GREEN}http://${ohrmIP}${ENDCOLOR} to access your OrangeHRM system!"
}

# Catch CTRL-C
trap early_exit SIGINT

if [[ -f "$FILE" ]]; then
	echo -e "${GREEN}OrangeHRM is installed!${ENDCOLOR}"
	exit 0
fi

show_start_message
check_prereq
get_license_agreement
get_config_values
create_containers
update_configuration
install_orangehrm
write_install_file
print_aws_ip

cleanup
exit 0
