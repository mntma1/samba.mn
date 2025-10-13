#!/usr/bin/env bash
docker compose -f /opt/samba/docker-compose.yaml down 
docker image rm c2635b16e76d # volumr ID => docker volume ls | grep samba
sudo rm -rfv /mnt/ssd/ /opt/samba/
exit 0

