#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
# Modifyed by Manfred - 28.10.2025

#-------------
# Colors
#-------------
CYN=`echo "\033[0;36m"`   # cyan
CYNB=`echo "\033[01;36m"` # cyan bold
BLU=`echo "\033[0;34m"`   # blue
BLUB=`echo "\033[01;34m"` # blue bold
RD=`echo "\033[01;31m"` # redi bold
GN=`echo "\033[1;92m"`  # green bold
BGN=`echo "\033[4;92m"` # green underline
DGN=`echo "\033[32m"`   # dark green
CL=`echo "\033[m"`      # clean
BFR="\\r\\033[K"        # clear and new line
HOLD="*"                # character in front of msg_info
CM="${GN}✓${C}"         # green hook
CROSS="${RD}✗${CL}"     # red cross

#------------------
# Verzeichnisse
#------------------
SSDDIR="/mnt/ssd"
SDIR="/mnt/ssd/storage"
DOCKERDIR="/opt/samba"
SMBCONF="/opt/samba/conf"

#-------------
# User
#-------------
USERSGRPID=100
SMBGID=101
USRID=1000
BUGID=1001

#-------------
# Backup User
#-------------
BUUSR="backupusr"
BGRP="@backupusr"
SMBUGRP="users"
SMBGRP="@users"

function check-inst {
if [ -d /tmp/samba ]; then 
   echo -e "$RD 

 Der SAMBA Container ist bereits installiert. 

$CL"
sleep 3
#clear
while true; do
    read -p "  Möchtest Du trotzdem mit der Installation fortfahren? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo 
            echo -e "$RD 

  Bitte antworte mit (j)a oder (n])in. 

$CL";;
    esac
done
 else
  echo -e "$GN    Installiere nun den SAMBA Container. $CL"
 sleep 3
fi

}

#------------------------------------------------------------------------------
# Beginn Installation
#------------------------------------------------------------------------------
function inst-info {
clear;

 echo -e "$GN

             -  INSTALLATION -

      SAMBA  in einem Docker Container

$CL"
}

#------------------------------------------------------------------------------
# Yes No
#------------------------------------------------------------------------------
function ja-nein {
echo
while true; do
    read -p " Mit der Installation fortfahren? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo;
echo -e "${RD}
 Bitte antworte mit (j)a oder (n)ein.         
${CL}";;
    esac
done
}

#------------------------------------------------------------------------------
# Erstellt die Verzeichnisse
#------------------------------------------------------------------------------
function mk-dirs {
echo
sudo rm -rf /mnt/samba/
sudo mkdir -p $SDIR/{Data,Backup}; sudo chown -R $USER: $SSDDIR
sudo mkdir -p $SMBCONF
sudo chown -R $USER: $DOCKERDIR
cp -f docker-compose-smb.yaml $DOCKERDIR 
cp -f install.sh $DOCKERDIR
sleep 3
}

# Abfrage der User-Daten 
function ask-userdata {
echo
echo Name des Admins.
echo Hier z.B. [$USER] 
echo ======================================
read -p "Den Benutzernamen bitte: " SMBUSER
echo
echo Das Passwort bitte, gut merken
echo ======================================
read -s -p "Das Passwort bitte: " PASSW
echo
# Backup User # neu
echo
echo Den Backup User anlegen.
echo Hier z.B. [Backupuser]
echo ======================================
read -p "Den Backup Benutzernamen bitte: " BUSER
echo
echo Das Passwort für den Backupuser, 
echo Bitte gut merken.
echo ======================================
read -s -p "Das Backup Passwort bitte: " BPASSW
echo
echo -e "$GN

    Benutzername:  $SMBUSER
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
 Bitte antworte mit (j)a oder (n)ein.
$CL ";;
    esac
done
}

#------------------------------------------------------------------------------
# Erstellt die users.conf
#------------------------------------------------------------------------------
function add-smbuser {
cat>/tmp/users.conf<<addsmbuser
$SMBUSER:$USRID:$SMBUGRP:$USERSGRPID:$PASSW
$BUSER:$BUGID:$BUUSR:$BUGID:$BPASSW 
addsmbuser
}

#------------------------------------------------------------------------------
# Erstellt die smb.conf
#------------------------------------------------------------------------------
function config-smb {
cat>/tmp/smb.conf<<configsmb
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

#------------------------------------------------------------------------------
# Kopiert die Konfigs 
#------------------------------------------------------------------------------
function copy-configs {
mv /tmp/smb.conf $SMBCONF
mv /tmp/users.conf $SMBCONF
}

function config-info {
cat<<info
===================================================
Der erste SMB-Benutzer ist: $SMBUSER und hat die UID:$USRID 
Der Backup-Benutzer ist: $BUSER und hat die UID:$BUGID 

Dies ist der neue Eintrag in der: $SMBCONF/users.conf

 $SMBUSER:$USRID:$SMBGRP:$SMBGID:$PASSW
 $BUSER:$BUGID:$BUUSR:$BUGID:$BPASSW 

info
}

#------------------------------------------------------------------------------
# Startet den Container
#------------------------------------------------------------------------------
function start-container {
cat<<startcontainer

  ....Starte den SAMBA Container

startcontainer
sleep 2

docker compose -f $DOCKERDIR/docker-compose.yaml up -d
}

function info-fertig {
echo -e "$GN

  ...Ferig

$CL";

docker stats --no-stream
sleep 3
}

# Yes or No
function add-user {
while true; do
    read -p " Möchtest Du  einen weiteren Samba Benutzer anlegen? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e " $RD Bitte antworte mit (ja) oder (nein). $CL ";;
    esac
done
./addUser.sh
}

#------------------------------------------------------------------------------
# installation finished
#------------------------------------------------------------------------------
function install-done {
echo -e "${GN} 



                   SAMBA DOCKER ist nun installiert!
${CL}"

echo -e "$CYNB

  Der SAMBA Container mit der Image-ID: $(docker ps|grep samba  | awk '{print $1}' | cut -d/ -f1) wurde hochgefahren.

  Die SMB-Freigaben: [Data] und [Backup]  sind jetzt erreichbar!

 -----------------------------------------------------------------------
  Im Filemanager eingeben:                                             
 -----------------------------------------------------------------------

  smb://$SMBUSER@$(hostname -I | awk '{print $1}' | cut -d/ -f1)/Data
  smb://$BUSER@$(hostname -I | awk '{print $1}' | cut -d/ -f1)/Backup
 
  oder
                                        
  smb://$SMBUSER@$HOSTNAME/Data
  smb://$BUSER@$HOSTNAME/Backu

 -----------------------------------------------------------------------
$CL"
}

# Install starts
clear
check-inst
inst-info
#ja-nein
mk-dirs
ask-userdata
yes-or-no
add-smbuser
clear
config-smb
copy-configs
config-info
start-container
clear
info-fertig
install-done
add-user
exit 0
