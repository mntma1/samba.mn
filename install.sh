#!/usr/bin/env bash
SDIR="/data/samba/storage"
SMBDIR="/data/samba/"
DOCKERDIR="/opt/samba"
SMBCONF="/opt/samba/conf"

# Instlliert den Docker SAMBA Server
sudo mkdir -p $SDIR/{Data,Backup} && sudo chown -Rv manfred: $SDIR/{Data,Backup}
sudo mkdir -pv $SDIR  
sudo chown -Rv manfred: $SMBDIR
sudo mkdir -pv $DOCKERDIR  && sudo chown -Rv manfred: $DOCKERDIR 

cp install.sh $DOCKERDIR


cat<<ende

========================================

And now....

 cd $DOCKERDIR && docker-compose up -d

========================================
ende
exit 0
