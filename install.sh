#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
#
#
# Colors
RD=`echo "\033[01;31m"` # red
GN=`echo "\033[1;92m"`  # green
BGN=`echo "\033[4;92m"` # green underline
DGN=`echo "\033[32m"`   # dark green
CL=`echo "\033[m"`      # clean
BFR="\\r\\033[K"        # clear and new line
HOLD="*"                # character in front of msg_info
CM="${GN}✓${C}"         # green hook
CROSS="${RD}✗${CL}"     # red cross

# Verzeichnisse
SSDDIR="/mnt/ssd"
SDIR="/mnt/ssd/storage"
DOCKERDIR="/optp/samba"
SMBCONF="/opt/samba/conf"

# User
SMBUGRP="users"
SMBGRP="@users"
USERSGRPID=100
SMBGID=101

# Backup User
BUUSR="backupusr"
BGRP="@backupusr"
BUGID=1004

clear;

# Beginn Installation
function inst-info {

 echo -e "$GN

             -  INSTALLATION -

      SAMBA  in einem Docker Container

$CL"
}

# Yes No
function ja-nein {
while true; do
    read -p " Mit der Installation fortfahren? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo; 
echo -e "${RD}    
 Bitte antworte mit [j]a oder [n]ein.         
${CL}";;
    esac
done
}

# Erstellt die Verzeichnisse
function mk-dirs {
sudo rm -rfv /tmp/samba/ /tmp/ssd/
sudo mkdir -pv $SDIR/{Data,Backup}; sudo chown -Rv $USER: $SSDDIR
sudo mkdir -pv $SMBCONF
sudo chown -Rv $USER: $DOCKERDIR
cp -fv docker-compose-smb.yaml $DOCKERDIR/docker-compose.yaml 
cp -fv test_install_SMB.sh $DOCKERDIR
sleep 3
}


# Abfrage der User-Daten 
function ask-userdata {
echo
echo Erforderliche bitte ausfüllen : 
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
# Backup User # neu
echo
echo Den Backup User anlegen
echo ======================================
read -p "Den Backup Benutzernamen  bitte: " BUSER
echo
echo Das Passwort für den Backupuser, bitte gut merken
echo ======================================
read -p "Das Backup Passwort bitte: " BPASSW


echo -e "$GN

    Benutzername:  $SMBUSER
          UserID:  $USRID
        Passwort:  $PASSW

  Backup Benutzer: $BUSER
  Backup Passwort: $BPASSW

$CL"
echo -e "$RD 

    Sind alle Angaben richtig?

$CL"
}

function yes-or-no {
while true; do
    read -p "  Mit der Installation fortfahren? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo; 
echo -e " $RD 
 Bitte antworte mit [j]a oder [n]ein. 
$CL ";;
    esac
done
}

clear;

# Erstellt die users.conf
function add-smbuser {
cat<<addsmbuser>/tmp/users.conf
$SMBUSER:$USRID:$SMBUGRP:$USERSGRPID:$PASSW
$BUSER:$BUGID:$BUUSR:$BUGID:$BPASSW 
addsmbuser
}

# Erstellt die smb.conf

function config-smb {
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
        valid users = $SMBUSER,$BUSER
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root
configsmb
}

# Kopiert die Konfigs 
function copy-configs {
mv /tmp/smb.conf $SMBCONF
mv /tmp/users.conf $SMBCONF
}

function config-info {
cat<<info
===================================================
Der neue SMB-Benutzer ist: $SMBUSER und hat die UID:$USRID 

Dies ist der neue Eintrag in der: $SMBCONF/users.conf

 $SMBUSER:$USRID:$SMBGRP:$SMBGID:$PASSW
 $BUSER:$BUGID:$BUUSR:$BUGID:$BPASSW 

info
}

# Startet den Container
function start-container {
cat<<startcontainer

  ....Starte den SAMBA Container

startcontainer
sleep 2

docker compose -f $DOCKERDIR/docker-compose.yaml up -d
}

function info-fertig {
cat<<fertig

...Ferig

fertig


docker stats --no-stream
sleep 3

cat<<ende

Der SAMBA Container mit der Image-ID: $(docker ps|grep samba-test  | awk '{print $1}' | cut -d/ -f1) wurde installiert.



Die SMB-Freigaben: [Data] und [Backup]  sind jetzt erreichbar!

Im Filemanager eingeben:

  smb://$(hostname -I | awk '{print $1}' | cut -d/ -f1)/Data | Backup 
 
 oder

  smb://$USER@$HOSTNAME/Data | Backup

ende
}

sleep 3

# Yes or No
function add-user {
while true; do
    read -p " Möchtest Du  einen wieteren Samba Benutzer anlegen? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e " $RD Bitte antworte mit [j]a oder [n]ein. $CL ;; "
    esac
done
./addUser.sh
}

# Install starts
inst-info
ja-nein
mk-dirs
ask-userdata
yes-or-no
add-smbuser
config-smb
copy-configs
config-info
start-container
add-user

exit 0
