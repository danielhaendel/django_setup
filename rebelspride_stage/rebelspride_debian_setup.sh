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
#!/bin/bash

# System-Update
apt-get update && apt-get upgrade -y

# Installation der notwendigen Pakete
apt-get install -y python3-pip python3-dev libpq-dev nginx git ufw

# Setzen des Hostnamens
hostnamectl set-hostname rebelspride
echo "rebelspride" > /etc/hostname

# Benutzer erstellen und zur sudo-Gruppe hinzufügen
adduser rebelspride
usermod -aG sudo rebelspride

# Virtual Environment einrichten
sudo -u rebelspride bash -c '
cd /home/rebelspride
python3 -m venv stage_env
source stage_env/bin/activate

# Django und Gunicorn installieren
pip install django gunicorn

# Django-Projekt initialisieren
django-admin startproject rebelspride .

# Gunicorn systemd Service-Datei erstellen
echo "[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=rebelspride
Group=www-data
WorkingDirectory=/home/rebelspride/rebelspride
ExecStart=/home/rebelspride/stage_env/bin/gunicorn \
          --workers 3 \
          --bind 0.0.0.0:8000 \
          rebelspride.wsgi:application


[Install]
WantedBy=multi-user.target" > /etc/systemd/system/gunicorn.service

# Gunicorn starten und aktivieren
systemctl start gunicorn
systemctl enable gunicorn

# Nginx-Konfiguration für das Projekt
echo "server {
    listen 80;
    server_name 192.168.56.10;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/rebelspride/rebelspride;
    }

    location / {
    proxy_pass http://192.168.56.10:8000;
    include proxy_params;
    }
}" > /etc/nginx/sites-available/rebelspride

# Symbolischer Link für Nginx
ln -s /etc/nginx/sites-available/rebelspride /etc/nginx/sites-enabled

# Default-Seite von Nginx entfernen
rm /etc/nginx/sites-enabled/default

# Firewall konfigurieren, um Nginx zuzulassen
ufw allow 'Nginx Full'

# Nginx neu starten
systemctl restart nginx
'

echo "Installation abgeschlossen...."
