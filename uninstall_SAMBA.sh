#!/usr/bin/env bash
# Created by Manfred - 14.10.2025
#
docker compose -f /opt/samba/docker-compose.yaml down 
docker image rm  $(docker image ls|grep samba | awk '{print $3}' | cut -d/ -f1)
sleep 3
sudo rm -rfv /mnt/ssd/ /opt/samba/
clear
cat<<ende


     Der Container SAMBA wurde deinstalliet!

ende
exit 0
