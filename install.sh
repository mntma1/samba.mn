#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
# Modifyed by Manfred - 28.10.2025

#-------------
# Colors
#-------------
source ./colors.env

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
USRID=1000
BUGID=1001

#-------------
# Backup User
#-------------
BUUSR="backupusr"
BGRP="@backupusr"

#-------------
#SMB User
#-------------
SMBUGRP="users"
USERSGID=100

#-------------
#SMB Gruppe
#-------------
SMBGRP="smb"
SMBGID=101

function check-inst {
if [ -d /opt/samba ]; then 
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
./uninstall_SAMBA.sh
echo
sudo rm -rf /mnt/samba/
sudo mkdir -p $SDIR/{Data,Backup}; sudo chown -R $USER: $SSDDIR
sudo mkdir -p $SMBCONF
sudo chown -R $USER: $DOCKERDIR
cp -f docker-compose.yaml $DOCKERDIR 
cp -f install.sh $DOCKERDIR
sleep 3
}

# Abfrage der User-Daten 
function ask-userdata {
echo
echo Name des Admins.
echo 'Darf auf [Data] & [Backup] (r/w) zugreifen' 
echo Hier z.B. [$USER] 
echo =============================================
read -p "Den Benutzernamen bitte: " SMBUSER
echo
echo Das Passwort bitte, gut merken
echo ======================================
read -s -p "Das Passwort bitte: " PASSW
echo
echo -e "$GN

             Admin:  $SMBUSER
          Passwort:  $PASSW

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
$SMBUSER:$USRID:$SMBGRP:$SMBGID:$PASSW
addsmbuser
}
#$BUSER:$BUGID:$SMBUGRP:$USERSGID:$BPASSW 

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
        valid users = @$SMBUGRP,$SMBUSER
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root

[Backup]
        path = /storage/Backup
        comment = Shared
        valid users = @$SMBGRP
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
 
  oder
                                        
  smb://$SMBUSER@$HOSTNAME/Data

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
