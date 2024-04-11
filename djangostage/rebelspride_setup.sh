# Copyright (c) 2024 danielhaendel
# Author: danielhaendel (Daniel Haendel)
# License: BOCHUM REBELS e.V.
# https://raw.githubusercontent.com/danielhaendel/django_setup/master/djangostage/rebelspride_setup.sh

clear
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe
echo -e "${RED}Welcome to RebelsPride Django Staging Server${NC}"
#echo "Welcome to rebelspride Django Staging Server"
echo ""
cat <<"EOF"
    ____       __         __     ____       _     __
   / __ \___  / /_  ___  / /____/ __ \_____(_)___/ /__
  / /_/ / _ \/ __ \/ _ \/ / ___/ /_/ / ___/ / __  / _ \
 / _, _/  __/ /_/ /  __/ (__  ) ____/ /  / / /_/ /  __/
/_/ |_|\___/_.___/\___/_/____/_/   /_/  /_/\__,_/\___/

                                     BOCHUM REBELS e.V.
EOF
echo ""
echo -e "Please wait, updating system..."
echo ""
#update system
sudo apt-get update
sudo apt-get upgrade -y
#add user to sudo group
apt install -y python3-pip python3-dev libpq-dev nginx git
#create new user
echo "Creating new user (rebelspride)..."
sleep 2
adduser rebelspride
echo "Adding user to sudo group..."
sleep 1
usermod -aG sudo rebelspride
echo "Switching to new user..."
sleep 1
su - rebelspride
#echo "Please enter the username for the new user:"
#read new_user
#if [ -z "$new_user" ]; then
#    echo "No username entered. Script will be terminated."
#    exit 1
#fi
#echo "Adding new user..."
