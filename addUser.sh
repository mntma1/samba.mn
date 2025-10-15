#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
#
# User
SMBUGRP="users"
SMBGRP="@users"
USERSGRPID=100
SMBGID=101

clear;
echo Einen neuen Benutzer erstellen
echo ======================================
read -p "Den Benutzernamen bitte:" SMBUSER  
echo
echo Diese  ID muss höher als 1000 sein'(1001 und fortlaufend)'
echo ======================================
read -p "Die UserID  bitte:" UUID
echo
echo Das Passwort bitte gut merken
echo ======================================
read -p "Das Passwort bitte:" PASSW

cat<<addsmbuser>>/opt/samba/conf/users.conf
$SMBUSER:$UUID:$SMBUGRP:$USERSGRPID:$PASSW
addsmbuser

cat<<ende

===================================================
Der neue SMB-Benutzer ist: $SMBUSER und hat die UID/GID: $SMBUID

Dies ist der neue Eintrag in der: /opt/samba/conf/users.conf

 $SMBUSER:$UUID:$SMBUGRP:$USERSGRPID:$PASSW

Vielen Dank.

ende
echo --------------------------------------------------------------------------------------
docker restart samba
sleep 3
docker logs samba
exit 0
#yesno  'Möchtest Du einen weiteren Benutzer anlegen?'
