#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
#

WT=`echo "\033[01;37m"`     # white
RD=`echo "\033[01;31m"`     # red
GN=`echo "\033[1;92m"`      # green 
BGN=`echo "\033[4;92m"`     # green underline
DGN=`echo "\033[32m"`       # dark green
CL=`echo "\033[m"`      # clean
BFR="\\r\\033[K"        # clear and new line
HOLD="*"            # character in front of msg_info
CM="${GN}✓${C}"     # green hook
CROSS="${RD}✗${CL}"     # red cross

# User
SMBUGRP="users"
SMBGRP="@users"
USERSGRPID=100
SMBGID=101

clear;
echo Einen weiteren Benutzer erstellen
echo ======================================
read -p "Den Benutzernamen bitte: " SMBUSER  
echo
echo Die  UID muss höher als 1000 sein'(1001 und fortlaufend)'
echo ======================================
read -p "Die UID  bitte: " UUID
echo
echo Das Passwort bitte gut merken
echo ======================================
read -p "Das Passwort bitte: " PASSW

cat>>/opt/samba/conf/users.conf<<addsmbuser
$SMBUSER:$UUID:$SMBUGRP:$USERSGRPID:$PASSW
addsmbuser

cat<<ende

===================================================
Der neue SMB-Benutzer ist: $SMBUSER und hat die UID/GID: $SMBUID

Dies ist der neue Eintrag in der: /opt/samba/conf/users.conf

 $SMBUSER:$UUID:$SMBUGRP:$USERSGRPID:$PASSW

===================================================
Vielen Dank.

ende
echo --------------------------------------------------------------------------------------
docker restart samba
sleep 3
docker logs samba

echo -e "$GN

          Einen weiteren Benutzer anlegen? 

$CL"

function  add-user {
while true; do
    read -p " Möchtest Du noch einen Samba Benutzer anlegen? (j/n): " yn
    case $yn in
        [Jj]* ) break;;
        [Nn]* ) exit;;
        * ) echo; 
echo -e "$RD                 
 Bitte antworte mit [j]a oder [n]ein.;;
$CL"

    esac
done
}
add-user
$0
exit 0
