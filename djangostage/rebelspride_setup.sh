# Copyright (c) 2024 danielhaendel
# Author: danielhaendel (Daniel Haendel)
# License: BOCHUM REBELS e.V.
# https://raw.githubusercontent.com/danielhaendel/django_setup/master/djangostage/rebelspride_setup.sh


echo "Welcome to Bochum Rebels Django Staging Server"
echo ""
cat <<"EOF"
    ____       __         __     ____       _     __
   / __ \___  / /_  ___  / /____/ __ \_____(_)___/ /__
  / /_/ / _ \/ __ \/ _ \/ / ___/ /_/ / ___/ / __  / _ \
 / _, _/  __/ /_/ /  __/ (__  ) ____/ /  / / /_/ /  __/
/_/ |_|\___/_.___/\___/_/____/_/   /_/  /_/\__,_/\___/

EOF
}
header_info
echo -e "Please wait, updating system..."
#update system
#sudo apt-get update
#sudo apt-get upgrade -y
##install python3
#sudo apt-get install python3 -y
##install pip3
#sudo apt-get install python3-pip -y
##create new user
#echo "Please enter the username for the new user:"
#read new_user
#if [ -z "$new_user" ]; then
#    echo "No username entered. Script will be terminated."
#    exit 1
#fi
#echo "Adding new user..."
