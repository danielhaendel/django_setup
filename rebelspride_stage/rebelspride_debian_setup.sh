# Copyright (c) 2024 danielhaendel
# Author: danielhaendel (Daniel Haendel)
# License: BOCHUM REBELS e.V.
# https://raw.githubusercontent.com/danielhaendel/django_setup/master/djangostage/rebelspride_setup.sh
#
# bash -c "$(wget -qO - https://raw.githubusercontent.com/danielhaendel/django_setup/master/rebelspride_stage/rebelspride_debian_setup.sh)"

clear
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White
NC='\033[0m' # Keine Farbe
echo -e "${Red}Welcome to RebelsPride Django Staging Server${NC}"
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
sleep 5
#update system
apt-get update && apt-get upgrade -y
apt-get install sudo -y
apt-get install ufw -y
hostnamectl set-hostname rebelspride
echo "rebelspride" > /etc/hostname
hostname
sleep 2
#add user to sudo group
apt-get install -y python3-pip python3-dev libpq-dev nginx git
#create new user
echo "Creating new user (rebelspride)..."
sleep 2
adduser rebelspride
echo "Adding user to sudo group..."
sleep 1
usermod -aG sudo rebelspride
echo "${Green}Switching to new user...${NC}"
sleep 2
sudo -u rebelspride bash -c '
echo "${Green}Installing NGINX...${NC}"
sleep 2
sudo apt install nginx
echo "${Green}Installing Python VEnv...${NC}"
sleep 2
sudo apt install -y python3-venv
echo "${Green}Changing directory...${NC}"
sleep 2
cd /home/rebelspride
echo "${Green}Creating new Python VEnv...${NC}"
sleep 2
python3 -m venv stage_env
source stage_env/bin/activate
echo "${Green}Install Django Project...${NC}"
pip install django
sleep 2
echo "${Green}Install Gunicorn...${NC}"
pip install gunicorn
echo "${Green}Initialize Django Projekt...${NC}"
django-admin startproject rebelspride
cd /rebelspride
python manage.py migrate
python manage.py collectstatic
echo "[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=rebelspride
Group=www-data
WorkingDirectory=/home/rebelspride/rebelspride/rebelspride
ExecStart=/home/rebelspride/stage_env/bin/gunicorn --workers 3 --bind unix:/home/rebelspride/rebelspride/rebelspride/rebelspride.sock rebelspride.wsgi:application

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/gunicorn.service
echo "Gunicorn config wurde erstellt..."
sleep 2
echo "server {
    listen 80;
    server_name 192.168.178.177;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/rebelspride/rebelspride;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/rebelspride/rebelspride/rebelspride/rebelspride.sock;
    }
}" > /etc/nginx/sites-available/rebelspride
echo "NGINX config wurde erstellt..."
sleep 2
sudo ln -s /etc/nginx/sites-available/rebelspride /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable gunicorn
sudo systemctl start gunicorn
'
sudo ufw allow 'Nginx Full'
su - rebelspride

#gunicorn --bind 0.0.0.0:8000 rebelspride.wsgi
