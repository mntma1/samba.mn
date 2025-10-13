#!/usr/bin/env bash
SDIR="/mnt/ssd/storage"
DOCKERDIR="/opt/samba"
SMBCONF="/opt/samba/conf"

# Instlliert den Docker SAMBA Server
sudo mkdir -pv $SDIR/{Data,Backup}
sudo mkdir -pv $SMBCONF
sudo chown -Rv manfred: $DOCKERDIR
cp -v docker-compose.yaml install.sh $DOCKERDIR
cp -v smb.conf users.conf $SMBCONF

sleep 3

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

Dies ist der neue Eintrag in der: $SMBCONF/users.conf

 $SMBUSER:$SMBUID:$SMBUSER:$SMBUID:$PASSW

ende
echo ----------------
sleep 2
docker-compose -f $DOCKERDIR/docker-compose.yaml up -d

cat<<ende

========================================

 And now fire up....

  cd $DOCKERDIR && docker-compose up -d
 oder:
  docker-compose -f $DOCKERDIR/docker-compose.yaml up -d
  
========================================

ende

cat<<fertig

Im Filemanager eingeben: smb://$USER@HOSTNAME/Data

Na denn -> Viel Apaß

fertig
sleep 2
docker logs samba
exit 0
