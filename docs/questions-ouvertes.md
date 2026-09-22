# Questions ouvertes

| # | Question | Impact |
|---|---|---|
| Q1 | Les caméras exposent-elles **RTSP/ONVIF** en local, ou uniquement Tuya cloud ? | Possibilité d'utiliser Frigate et de couper Internet aux caméras |
| Q2 | Souhaitez-vous conserver l'appli **Tuya/Smart Life** pour la vidéo, ou basculer vers Frigate (+ accès via VPN) ? | Règles pare-feu VLAN CAM |
| Q3 | À quoi servent aujourd'hui la **MANTBox, la NanoBeam, la LiteAP AC et les Loco AC** ? Existe-t-il une liaison radio entre bâtiments / avec un site proche ? | Topologie physique, trunk VLAN radio |
| Q4 | Distance entre résidence et bureau ? Visibilité directe (radio possible) ? | Alternative/secours au tunnel Internet |
| Q5 | Les box sont-elles derrière du **CGNAT** (IP WAN de la box ≠ IP publique vue de l'extérieur) ? | Faisabilité du tunnel direct |
| Q6 | Quels services doivent être accessibles depuis Internet (hors VPN) ? | Publication via le VPS (reverse proxy) |
| Q7 | Nombre d'utilisateurs / postes au bureau ? Besoin d'un Wi-Fi invités ? | Dimensionnement AP et VLAN GUEST |
| Q8 | Rétention vidéo souhaitée (jours) ? | Taille des disques de surveillance |
| Q9 | Préférence Zabbix vs LibreNMS (ou déjà une habitude) ? | Choix de la stack de supervision |
