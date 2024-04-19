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

# Prüfe, ob das Skript als Root ausgeführt wird
if [ "$(id -u)" != "0" ]; then
   echo "Dieses Skript muss als Root ausgeführt werden" 1>&2
   exit 1
fi

# Beginne mit der eigentlichen Installation

# System-Update
apt-get update && apt-get upgrade -y

# Installation der notwendigen Pakete
apt-get install -y python3-pip python3-dev libpq-dev nginx git ufw

# Setzen des Hostnamens
hostnamectl set-hostname rebelspride
echo "rebelspride" > /etc/hostname

# Erstellen und zur sudo-Gruppe hinzufügen des Benutzers erfolgt hier nicht mehr, da das Skript als Root ausgeführt wird.


# Führe die nächsten Befehle als Benutzer "rebelspride" aus
su rebelspride -c "cd ~ && \
# Frage nach dem GitHub Personal Access Token
read -p "Bitte gib dein GitHub Personal Access Token ein: " token
read -p "Bitte gib deinen GitHub Benutzernamen ein: " username
read -p "Bitte gib den Namen des Repositories ein, das du klonen möchtest: " repo
git clone https://$token@github.com/$username/$repo && \
cd $repo && \
python3 -m venv stage_env && \
source stage_env/bin/activate && \
pip install django gunicorn python-dotenv && \
django-admin startproject $repo . && \
cd $repo && \
python manage.py migrate && \
python manage.py collectstatic --noinput"

# Gunicorn systemd Service-Datei erstellen
cat > /etc/systemd/system/gunicorn.service << EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=rebelspride
Group=www-data
WorkingDirectory=/home/rebelspride/rebelspride/rebelspride
ExecStart=/home/rebelspride/stage_env/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 rebelspride.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Gunicorn starten und aktivieren
systemctl start gunicorn
systemctl enable gunicorn

# Nginx-Konfiguration für das Projekt
cat > /etc/nginx/sites-available/rebelspride << EOF
server {
    listen 80;
    server_name 192.168.1.123; # Ersetze dies durch deine Domain oder IP-Adresse

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/rebelspride/rebelspride;
    }

    location / {
    include proxy_params;
    proxy_pass http://127.0.0.1:8000;
    }
}
EOF

# Symbolischen Link für Nginx entfernen, falls vorhanden
sudo rm /etc/nginx/sites-enabled/rebelspride
# Symbolischen Link für Nginx erstellen
ln -s /etc/nginx/sites-available/rebelspride /etc/nginx/sites-enabled/rebelspride || true

# Default-Seite von Nginx entfernen
rm -f /etc/nginx/sites-enabled/default

# Firewall konfigurieren, um Nginx zuzulassen
ufw allow 'Nginx Full'

# Nginx neu starten
systemctl restart nginx
systemctl daemon-reload
systemctl restart gunicorn

echo "Installation abgeschlossen."
