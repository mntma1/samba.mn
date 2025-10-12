#!/usr/bin/env bash
#read -p "Mötest du noch einen weiteren Samba User hinzufügen?" SMBUSER  
clear;
echo Erforderliche Angaben sind: 
echo Benutzername, UserID[N] und das Passwort.
echo ======================================
read -p "Den Benutzernamen bitte:" SMBUSER  
echo Diese  ID '(ab 1000 und fortlaufend)' wird in SAMBA neu erstellt
echo und hat mit dem lockalem User nichts zu tun.
read -p "Die UserID  bitte:" SMBUID
read -p "Das Passwort bitte:" PASSW

cat<<addsmbuser>>/opt/samba/conf/users.conf
$SMBUSER:$SMBUID:$SMBUSER:$SMBUID:$PASSW
addsmbuser

cat<<ende

===================================================
Der neue SMB-Benutzer ist: $SMBUSER und hat die UID/GID: $SMBUID

Dies ist der neue Eintrag in der: /opt/samba/conf/users.conf

 $SMBUSER:$SMBUID:$SMBUSER:$SMBUID:$PASSW

Vielen Dank.

ende
echo --------------------------------------------------------------------------------------
docker restart samba
sleep 3
docker logs samba
exit 0
