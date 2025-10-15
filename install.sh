#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
#
# Verzeichnisse
SSDDIR="/mnt/ssd"
SDIR="/mnt/ssd/storage"
DOCKERDIR="/opt/samba"
SMBCONF="/opt/samba/conf"

# User
SMBUGRP="users"
SMBGRP="@users"
USERSGRPID=100
SMBGID=101

# Backup User
BGRP="@backupusr"

# Erstellt die Verzeichnisse
clear;
sudo mkdir -p $SDIR/{Data,Backup}; sudo chown -Rv $USER: $SSDDIR
sudo mkdir -p $SMBCONF
sudo chown -R $USER: $DOCKERDIR
cp docker-compose.yaml install.sh $DOCKERDIR

cat<<anfang

Installiere den SAMBA Container 
Bitte warten....

anfang

sleep 3
clear;

# Abfrage der User-Daten 
echo Erforderliche Angaben sind: 
echo ======================================
read -p "Den Benutzernamen bitte: " SMBUSER
echo
echo Diese  ID '(ab 1000 und fortlaufend)' wird in SAMBA neu erstellt
echo und hat mit dem lockalem User nichts zu tun.
echo ======================================
read -p "Die UserID  bitte: " USRID
echo
echo Das Passwort bitte, gut merken
echo ======================================
read -p "Das Passwort bitte: " PASSW


clear;
# neu
# Erstellt die users.conf
cat<<addsmbuser>/tmp/users.conf
$SMBUSER:$USRID:$SMBUGRP:$USERSGRPID:$PASSW
addsmbuser

# neu
# Erstellt die smb.conf
cat<<configsmb>/tmp/smb.conf
[global]
        server string = samba
        idmap config * : range = 3000-7999
        security = user
        server min protocol = SMB2

        # disable printing services
        load printers = no
        printing = bsd
        printcap name = /dev/null
        disable spoolss = yes

[Data]
        path = /storage/Data
        comment = Shared
        valid users = $SMBGRP 
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root

[Backup]
        path = /storage/Backup
        comment = Shared
        valid users = $SMBUSER
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root
configsmb

# Kopiert die Konfigs 
mv /tmp/smb.conf $SMBCONF
mv /tmp/users.conf $SMBCONF

cat<<info
===================================================
Der neue SMB-Benutzer ist: $SMBUSER und hat die UID:$USRID 

Dies ist der neue Eintrag in der: $SMBCONF/users.conf

 $SMBUSER:$USRID:$SMBGRP:$SMBGID:$PASSW
 
 $SMBUSER ist auch der Backup-User

Neu Benutzer können mit: addUser.sh angelegt werden.

info

# Startet den Container
sleep 2
cat<<startcontainer

  ....Starte den SAMBA Container

startcontainer

docker compose -f $DOCKERDIR/docker-compose.yaml up -d

cat<<fertig

...Ferig

fertig

sleep 3

docker logs samba

cat<<ende

Der SAMBA Container mit der Image-ID: $(docker ps|grep samba  | awk '{print $1}' | cut -d/ -f1) wurde installiert.



Die SMB-Freigaben: [Data] und [Backup]  sind jetzt erreichbar!

Im Filemanager eingeben:

  smb://$(hostname -I | awk '{print $1}' | cut -d/ -f1)/Data | Backup 
 
 oder

  smb://$USER@$HOSTNAME/Data | Backup

ende

exit 0
