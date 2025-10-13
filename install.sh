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

cat<<ende

========================================

And now fire up....

 cd $DOCKERDIR && docker-compose up -d
oder:
 docker-compose -f $DOCKERDIR/docker-compose.yaml up -d
========================================

ende
exit 0
