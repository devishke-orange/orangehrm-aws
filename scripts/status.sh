RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
ENDCOLOR="\e[0m"

if [[ -z "/home/ec2-user/orangehrm-aws/installed" ]]
then
    echo -e "\n#################################################################"
    echo "#								#"
    echo -e "#	             ${GREEN}OrangeHRM is installed!${ENDCOLOR}			#"
    echo "#								#"
    echo -e "#################################################################\n"

else
    echo -e "\n#################################################################"
    echo "#								#"
    echo -e "#	         ${YELLOW}OrangeHRM is not installed!${ENDCOLOR}			#"
    echo -e "#	Run ${GREEN}orangehrm install${ENDCOLOR} to start the installation		#"
    echo "#								#"
    echo -e "#################################################################\n"
fi
