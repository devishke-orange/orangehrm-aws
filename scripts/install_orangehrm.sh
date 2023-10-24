#!/bin/bash

FILE=/home/ec2-user/orangehrm-aws/installed

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"

cleanup () {
	unset firstName
	unset lastName
	unset email
	unset username
	unset password
	unset password2
	unset orgName
	unset confirm
	unset country
	unset licenseConfirm
	unset encrypt
	unset encryptOption
	unset RED
	unset GREEN
	unset ENDCOLOR
	unset TOKEN
	unset OHRM_IP
}

check_prereq () {
	# Check if docker is installed
	if ! [[ $(command -v docker) ]]
	then
		echo -e "${RED}Docker is not installed! Please report this!${ENDCOLOR}"
		exit 1
	fi

	# Check if the docker service is active
	if [[ $(sudo systemctl is-active docker) = "inactive" ]]
	then
		echo -e "${RED}Docker is not active!${ENDCOLOR}"
		echo -e "Please activate docker using ${GREEN}sudo systemctl start docker${ENDCOLOR} and retry the installation"
		echo -e "If you want docker to start on boot you can run ${GREEN}sudo systemctl enable docker${ENDCOLOR} as well"
		exit 1
	fi
}

early_exit () {
	echo -e "\n${RED}Quitting the installation..${ENDCOLOR}"
	echo -e "${YELLOW}Cleaning install files${ENDCOLOR}............🚧"

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
	echo -e "${GREEN}Cleaning install files${ENDCOLOR}............✅"
	echo -e "You can run \"${GREEN}orangehrm install${ENDCOLOR}\" to restart the installation${ENDCOLOR}"
	cleanup
	exit 0
}

# Catch CTRL-C
trap early_exit SIGINT

if [[ -f "$FILE" ]]; then
	echo -e "${GREEN}OrangeHRM is installed!${ENDCOLOR}"
else
	clear
	cat /home/ec2-user/.orangehrm/assets/LOGO
	echo -e "\n${GREEN}Starting the OrangeHRM Installation${ENDCOLOR}\n"
	echo -e "${YELLOW}Checking pre-requisites${ENDCOLOR}...........🚧"
	check_prereq
	tput cuu1
	echo -e "${GREEN}Checking pre-requisites${ENDCOLOR}...........✅\n"
	confirm="no"
	echo -ne "Please read and agree to the following license ${YELLOW}[press enter]${ENDCOLOR}"
	read -r
	tput cuu1
	tput el
	less -P "Press ENTER to read more, press q to quit" /home/ec2-user/.orangehrm/assets/LICENSE
	echo -e "Do you agree to the license? ${YELLOW}[yes/no]${ENDCOLOR}"
	read -rp "> " licenseConfirm
	while ! [[ $licenseConfirm =~ ^y(e|es)?$|^n(o)?$ ]]
	do
		echo -e "\n${RED}Invalid input${ENDCOLOR}"
		echo -e "Do you agree to the license? ${YELLOW}[yes/no]${ENDCOLOR}"
		read -rp "> " licenseConfirm
	done
	if [[ $licenseConfirm =~ ^n(o)?$ ]]
	then
		early_exit
	fi
	while ! [[ $confirm =~ ^y(e|es)?$ ]]
	do
		echo -e "Enter the admin employee's first name ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " firstName
		while [[ -z "$firstName" ]]
		do
			echo -e "${RED}The first name cannot be empty!${ENDCOLOR}"
			echo -e "Enter the admin employee's first name ${YELLOW}[required]${ENDCOLOR}"
			read -rp "> " firstName
		done
		echo -e "Enter the admin employee's last name ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " lastName
		while [[ -z "$lastName" ]]
		do
			echo -e "${RED}The last name cannot be empty!${ENDCOLOR}"
			echo -e "Enter the admin employee's last name ${YELLOW}[required]${ENDCOLOR}"
			read -rp "> " lastName
		done
		echo -e "Enter the admin employee's email ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " email
		while [[ -z "$email" ]]
		do
			echo -e "${RED}The email cannot be empty!${ENDCOLOR}"
			echo -e "Enter the admin employee's email ${YELLOW}[required]${ENDCOLOR}"
			read -rp "> " email
		done
		echo -e "Enter the name of your organization ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " orgName
		while [[ -z "$orgName" ]]
		do
			echo -e "${RED}The organisation name cannot be empty!${ENDCOLOR}"
			echo -e "Enter the name of your organization ${YELLOW}[required]${ENDCOLOR}"
			read -rp "> " orgName
		done
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
		echo -e "Enter the admin username ${YELLOW}[required]${ENDCOLOR}"
		read -rp "> " username
		while [[ -z "$username" ]]
		do
			echo -e "${RED}The username cannot be empty!${ENDCOLOR}"
			echo -e "Enter the admin username ${YELLOW}[required]${ENDCOLOR}"
			read -rp "> " username
		done
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
		echo -e "\nDo you want to enable data encryption? ${YELLOW}[yes/no]${ENDCOLOR}"
		read -rp "> " encrypt
		while ! [[ $encrypt =~ ^y(e|es)?$|^n(o)?$ ]]
		do
			echo -e "\n${RED}Invalid input${ENDCOLOR}"
			echo -e "Do you want to enable data encryption? ${YELLOW}[yes/no]${ENDCOLOR}"
			read -rp "> " encrypt
		done
		if [[ $encrypt =~ ^y(e|es)?$ ]]
		then
			encryptOption="y"
		else
			encryptOption="n"
		fi
		echo -e "\nPlease confirm the following"
		echo "==============================="
		echo -e "${GREEN}First Name${ENDCOLOR}: 	    $firstName"
		echo -e "${GREEN}Last Name${ENDCOLOR}: 	    $lastName"
		echo -e "${GREEN}Work Email${ENDCOLOR}: 	    $email"
		echo -e "${GREEN}Org Name${ENDCOLOR}: 	    $orgName"
		echo -e "${GREEN}Country${ENDCOLOR}:	    $country"
		echo -e "${GREEN}Username${ENDCOLOR}: 	    $username"
		echo -e "${GREEN}Data Encryption${ENDCOLOR}:    $encryptOption"
		echo "==============================="
		echo -e "\nAre these details correct? ${YELLOW}[yes/no]${ENDCOLOR}"
		read -rp "> " confirm
		while ! [[ $confirm =~ ^y(e|es)?$|^n(o)?$ ]]
		do
			echo -e "\n${RED}Invalid input${ENDCOLOR}"
			echo -e "Are these details correct? ${YELLOW}[yes/no]${ENDCOLOR}"
			read -rp "> " confirm
		done
		if [[ $confirm =~ ^n(o)?$ ]]
		then
			echo -e "\n${RED}Please re-enter the details${ENDCOLOR}"
		fi
	done
	echo -e "\n${YELLOW}Downloading install files${ENDCOLOR}.........🚧"
	git clone https://github.com/devishke-orange/orangehrm-aws /home/ec2-user/orangehrm-aws &> /dev/null
	tput cuu1
	echo -e "${GREEN}Downloading install files${ENDCOLOR}.........✅"
	echo -e "${YELLOW}Creating the containers${ENDCOLOR}...........🚧"
	docker compose -f /home/ec2-user/orangehrm-aws/compose.yml up -d --remove-orphans &> /dev/null
	tput cuu1
	echo -e "${GREEN}Creating the containers${ENDCOLOR}...........✅"
	sleep 5
	echo -e "${YELLOW}Updating install configuration${ENDCOLOR}....🚧"
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
	echo -e "${GREEN}Updating install configuration${ENDCOLOR}....✅"
	echo -e "${YELLOW}Installing OrangeHRM${ENDCOLOR}..............🚧"
	docker exec ohrm php installer/cli_install.php &> /dev/null
	tput cuu1
	echo -e "${GREEN}Installing OrangeHRM${ENDCOLOR}..............✅"
	printf "DO NOT DELETE THIS FILE!
This file let's the instance know that OrangeHRM is installed!
If you delete this file, the instance will run an install script the next time you SSH into this instance." > $FILE
	echo -e "\n${GREEN}OrangeHRM is finished installing!${ENDCOLOR}"
	TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
	OHRM_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
	echo -e "\nVisit ${GREEN}http://${OHRM_IP}${ENDCOLOR} to access your OrangeHRM system!"
	cleanup
fi
