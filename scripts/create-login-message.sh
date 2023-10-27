#!/bin/bash

STATUS_SCRIPT=/home/ec2-user/.orangehrm/scripts/status.sh
LOGIN_SCRIPT=/home/ec2-user/login_orangehrm.sh

cleanup() {
    unset STATUS_SCRIPT
    unset LOGIN_SCRIPT
}

printf "#!/bin/bash\n\n" > $LOGIN_SCRIPT

{
printf "supress_message() {\n"
printf "    echo -e \"To supress this message please remove login_orangehrm.sh from /etc/profile.d\\\n\"\n"
printf "}\n\n"

printf "if ! [[ -f %s ]]; then\n" $STATUS_SCRIPT
printf "    echo \"The status script has been removed!\"\n"
printf "    supress_message\n" 
printf "fi\n\n"

printf "sh %s\n" $STATUS_SCRIPT
printf "supress_message"
} >> $LOGIN_SCRIPT

echo -e "\nThe login script has been created  at ${LOGIN_SCRIPT}"
echo -e "Please move it to /etc/profile.d/\n"

cleanup
exit 0
