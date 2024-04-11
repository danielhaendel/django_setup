#!/bin/bash

# Aktualisiere alle Pakete
echo "Aktualisiere alle Pakete..."
apt-get update && apt-get upgrade -y

# Frage nach dem Benutzernamen
echo "Bitte geben Sie den Benutzernamen für den neuen Benutzer ein:"
read neuer_benutzer

# Überprüfe, ob der Benutzername nicht leer ist
if [ -z "$neuer_benutzer" ]; then
    echo "Kein Benutzername eingegeben. Skript wird beendet."
    exit 1
fi

# Füge einen neuen Benutzer hinzu
echo "Füge neuen Benutzer hinzu..."
adduser "$neuer_benutzer" --gecos "" --disabled-password

# Frage nach dem Passwort
echo "Bitte geben Sie das Passwort für den neuen Benutzer ein (Eingabe wird nicht angezeigt):"
read -s passwort_neuer_benutzer

# Überprüfe, ob das Passwort nicht leer ist
if [ -z "$passwort_neuer_benutzer" ]; then
    echo "Kein Passwort eingegeben. Skript wird beendet."
    exit 1
fi

# Setze das Passwort für den neuen Benutzer
echo "$neuer_benutzer:$passwort_neuer_benutzer" | chpasswd

# Gewähre dem neuen Benutzer Sudo-Rechte
echo "Gewähre Sudo-Rechte..."
usermod -aG sudo "$neuer_benutzer"

echo "Setup abgeschlossen. Wechsel zu dem neuen Benutzer mit: su - $neuer_benutzer"