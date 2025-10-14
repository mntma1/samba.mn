#!/usr/bin/env bash
docker compose -f /opt/samba/docker-compose.yaml down 
docker image rm  $(docker image ls|grep samba | awk '{print $3}' | cut -d/ -f1)
sudo rm -rfv /mnt/ssd/ /opt/samba/
sleep 3
clear
cat<<ende


     Der Container SAMBA wurde deinstalliet!

ende
exit 0
