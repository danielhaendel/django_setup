###########################################################
###   bash script für django server                     ###
###   author daniel haendel                             ###
###########################################################


#welcome to rebelspride
echo "Welcome to Rebelspride"
echo "
    	"
echo "
    ____       __         __     ____       _     __
   / __ \___  / /_  ___  / /____/ __ \_____(_)___/ /__
  / /_/ / _ \/ __ \/ _ \/ / ___/ /_/ / ___/ / __  / _ \
 / _, _/  __/ /_/ /  __/ (__  ) ____/ /  / / /_/ /  __/
/_/ |_|\___/_.___/\___/_/____/_/   /_/  /_/\__,_/\___/"

sleep 5
echo "Please wait, updating system..."
#update system
sudo apt-get update
sudo apt-get upgrade -y
#install python3
sudo apt-get install python3 -y
#install pip3
sudo apt-get install python3-pip -y
#create new user
echo "Please enter the username for the new user:"
read new_user
if [ -z "$new_user" ]; then
    echo "No username entered. Script will be terminated."
    exit 1
fi
echo "Adding new user..."
