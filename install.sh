#!/usr/bin/env bash
SDIR="/data/samba/storage"
SMBDIR="/data/samba/"
DOCKERDIR="/opt/samba"

# Instlliert den Docker SAMBA Server
sudo mkdir -pv $SDIR  
sudo chown -Rv manfred: $SMBDIR
sudo mkdir -pv $DOCKERDIR  && sudo chown -Rv manfred: $DOCKERDIR 

cp install.sh $DOCKERDIR

cat<<smbconf>$SMBDIR/smb.conf
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

[Backup]
        path = /storage
        comment = Shared
        valid users = @smb
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root
smbconf

cat<<DockerCompose>$DOCKERDIR/docker-compose.yaml
services:
  samba:
    image: dockurr/samba
    container_name: samba
    environment:
      NAME: "Data"
      USER: "manfred"
      PASS: "prometheus"
      UID: "1000"
      GID: "1000"
    ports:
      - 445:445
    volumes:
      - /data/samba/storage:/storage
      - /data/samba/smb.conf:/etc/samba/smb.conf
    restart: always
DockerCompose

cat<<ende

========================================

And now....

 cd $DOCKERDIR && docker-compose up -d

========================================
ende
exit 0
