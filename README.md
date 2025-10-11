# Ein SAMBA Server als Docker Container

<img width="1552" height="272" alt="SAMBA" src="https://github.com/user-attachments/assets/522e97c1-41b5-4488-b7bc-479bdf066857" />

**Siehe:** [Projektseite](https://hub.docker.com/r/dockurr/samba)

> [!IMPORTANT] 
> Als User, nicht als root!
```
git clonehttps://github.com/mntma1/samba.mn
```

## Führe nun folgende Befehle aus:
```
cd samba.mn
./install.sh

cd /opt/samba
```
**In File: docker-compose.yaml** 

```
# Folgene Zeilen nur links vom Dopelpunkt :) anpassen.

# Zeile 7 u. 8
environment:
  USER=Benutzername
  PASS=Passwort

# Zeile 14 u. 15
volumes:
  - /Pfad/zum/storage:storage # zB. /mnt/ssd
  - /Pfad/zumr/smb.conf:/etc/samba/smb.conf
```

```
docker-compose up -d
```

# Viel Spaß!
