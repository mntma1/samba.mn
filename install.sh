#!/usr/bin/env bash
SDIR="/mnt/ssd/storage"
DOCKERDIR="/opt/samba"
SMBCONF="/opt/samba/conf"
SMBGRP="smb"
SMBGID=101

# Erstellt die Verzeichnisse
clear;
sudo mkdir -pv $SDIR/{Data,Backup}
sudo mkdir -pv $SMBCONF
sudo chown -Rv $USER: $DOCKERDIR
cp -v docker-compose.yaml install.sh $DOCKERDIR
#cp -v smb.conf users.conf $SMBCONF

sleep 5

clear;

# Abfrage der User-Daten 
echo Erforderliche Angaben sind: 
echo Benutzername, UserID[N] und das Passwort.
echo ======================================
read -p "Den Benutzernamen bitte:" SMBUSER
echo Diese  ID '(ab 1000 und fortlaufend)' wird in SAMBA neu erstellt
echo und hat mit dem lockalem User nichts zu tun.
read -p "Die UserID  bitte:" USRID
read -p "Das Passwort bitte:" PASSW

clear;

# Erstellt die users.conf
cat<<addsmbuser>/tmp/users.conf
$SMBUSER:$USRID:$SMBGRP:$SMBGID:$PASSW
addsmbuser

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
        valid users = @smb 
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root

[Backup]
        path = /storage/Backup
        comment = Shared
        valid users = @smb
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root
configsmb

# Kopiert die Konfigs 
mv /tmp/smb.conf $SMBCONF
mv /tmp/users.conf $SMBCONF

cat<<ende
===================================================
Der neue SMB-Benutzer ist: $SMBUSER und hat die UID/GID: $SMBUID

Dies ist der neue Eintrag in der: $SMBCONF/users.conf

 $SMBUSER:$SMBUID:$SMBGRP:$SMBGID:$PASSW

ende

echo ----------------

sleep 2

# Startet den Container
docker compose -f $DOCKERDIR/docker-compose.yaml up -d

cat<<fertig

Die SMB-Freigabein: Data und Backup sind nun erreichbar mit:

Im Filemanager eingeben:

  smb://$(hostname -I | awk '{print $1}' | cut -d/ -f1)/Data | Backup 
 
 oder

  smb://$USER@$HOSTNAME/Data | Backup

fertig

sleep 3
docker logs samba
exit 0
