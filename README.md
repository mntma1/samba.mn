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
# Folgene Zeilen(Nur links vom Dopelpunkt) anpassen.
# Zeile 14 u. 15
volumes:
  - /Pfad/zum/storage:storage # zB. /mnt/ssd
  - /Pfad/zur/smb.conf:/etc/samba/smb.conf
```

**Dateien in /opt/samba/conf anpassen.**
```
# users.conf
-> Username:1000:Grupenname:1000:einSicheresPasswort
```
```
# smb.conf
[Data]
-> valid users = Username

[Backup]
-> valid users = Username
```

**Docker eretellen mit:**
```
docker-compose up -d
```

**So ereichst du die SAMBA-Pools [Data,Backup]**

<img width="688" height="171" alt="Bildschirmfoto zu 2025-10-12 02-21-08" src="https://github.com/user-attachments/assets/bfc5ddc5-e098-4cc2-a100-9162e1c5a58d" />


# Viel Spaß!
