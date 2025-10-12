#!/usr/bin/env bash
SDIR="/opt/samba/storage"
DOCKERDIR="/opt/samba"
SMBCONF="/opt/samba/conf"

# Instlliert den Docker SAMBA Server
sudo mkdir -pv $SDIR/{Data,Backup}
sudo mkdir -pv $SMBCONF
sudo chown -Rv manfred: $DOCKERDIR

cp docker-compose.yaml install.sh $DOCKERDIR
cp smb.conf users.conf $SMBCONF

cat<<ende

========================================

And now....

 cd $DOCKERDIR && docker-compose up -d

========================================

ende
exit 0
