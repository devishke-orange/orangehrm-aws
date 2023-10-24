RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"

echo -e "${YELLOW}Checking pre-requisites${ENDCOLOR}...........🚧"

# Check if git is installed
if ! [[ $(command -v git) ]]
then
    echo -e "{RED}git is not installed!${ENDCOLOR}"
    echo "Please install git and try running the script again"
fi
tput cuu1
echo -e "${GREEN}Checking pre-requisites${ENDCOLOR}...........✅"

# Clone the repository
echo -e "${YELLOW}Cloning the repository${ENDCOLOR}............🚧"
if ! [[ -d "/home/ec2-user/.orangehrm" ]]
then
    git clone --progress https://github.com/devishke-orange/orangehrm-aws /home/ec2-user/.orangehrm &>/home/ec2-user/repo_log.txt
    mkdir /home/ec2-user/.orangehrm/logs
    mv /home/ec2-user/repo_log.txt /home-ec2-user/repo_log.txt /home/ec2-user/.orangehrm/logs/repo_log.txt
fi
tput cuu1
echo -e "${GREEN}Cloning the repository${ENDCOLOR}............✅"

# Write the alias to .bashrc
echo -e "${YELLOW}Writing alias to .bashrc${ENDCOLOR}..........🚧"
if ! [[ $(grep orangehrm < /home/ec2-user/.bashrc) ]]
then
    echo -e "\n\n# This alias is related to the orangehrm command" >> /home/ec2-user/.bashrc
    echo "alias orangehrm='sh /home/ec2-user/.orangehrm/scripts/orangehrm.sh'" >> /home/ec2-user/.bashrc
fi
tput cuu1
echo -e "${GREEN}Writing alias to .bashrc${ENDCOLOR}..........✅"

echo -e "\nPlease run ${YELLOW}source /home/ec2-user/.bashrc${ENDCOLOR} to activate the ${GREEN}orangehrm${ENDCOLOR} command"

unset RED
unset GREEN
unset YELLOW
unset ENDCOLOR
