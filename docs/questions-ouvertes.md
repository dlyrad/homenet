# Questions ouvertes

## Tranchées

| # | Question | Réponse | Conséquence |
|---|---|---|---|
| Q1 | Caméras RTSP/ONVIF ? | ONVIF | Frigate possible |
| Q2 | Garder l'appli Tuya ? | Pas nécessaire | VLAN CAM coupé d'Internet, vue distante par VPN |
| Q3 | Usage des radios | MANTBox = hotspot ; NanoBeam → relais LiteAP/Loco pour les proches | Zones HOTSPOT (70) et RELAIS (80) isolées + QoS |
| Q4 | Liaison radio résidence ↔ bureau ? | Non (obstacles) | Interconnexion uniquement par Internet |
| Q5 | CGNAT ? | Non : IP publique sur la box, LAN `192.168.1.x` | Tunnels directs + DDNS ; VPS en secours |
| Q8 | Rétention vidéo | ≥ 3 semaines | 0,5–1 To par caméra en continu, stockage par site |
| Q10 | Caméras par site | 3 résidence, 3 bureau | 1 disque de 4 To par site ; 1,5 Mb/s de sous-flux inter-sites |
| Q20 | La MANTBox a-t-elle des comptes/tickets hotspot ? | Oui | Export/import vers le hAP ax³ à l'étape B |
| Q17 | Version RouterOS du hAP ax³ | 7.23.7 (long-term) | Script `configs/res-rtr-01.rsc` |
| Q18 | Où tourne le portail captif ? | *Par défaut* : sur le hAP ax³ (option A) | À confirmer |
| Q19 | Débit réservé hotspot/proches | *Par défaut* : 6/40 Mb/s chacun, 2/6 Mb/s par client hotspot | À ajuster après mesure |

## À trancher

| # | Question | Impact |
|---|---|---|
| Q11 | Les NVR ont-ils des disques ? Quelle capacité ? Enregistrent-ils en ONVIF sans cloud ? | Garder les NVR en secours ou les retirer |
| Q12 | Modèle exact des mini-serveurs Dell (ou modèle du Xeon) ? | iGPU pour Frigate au bureau, ou Coral à prévoir |
| Q13 | Combien de clients sur le hotspot, combien de proches sur le relais ? Le hotspot est-il payant (tickets) ? | Taille des VLAN, User Manager, plafonds QoS |
| Q14 | Le point relais (LiteAP/Loco) est-il chez quelqu'un ? A-t-il du courant secouru ? | Supervision et onduleur du relais |
| Q15 | Les CPE des proches (LiteBeam/Loco) sont-ils à vous et administrables ? | Supervision complète ou simple ping |
| Q16 | Les box acceptent-elles une **DMZ** ou une redirection UDP ? | Tunnel direct, sinon passage obligé par le VPS |
| Q6 | Quels services doivent être accessibles depuis Internet hors VPN ? | Publication via le VPS (reverse proxy) |
| Q7 | Nombre d'utilisateurs/postes au bureau ? | Dimensionnement des AP |
| Q9 | Zabbix ou LibreNMS ? | Choix de la stack de supervision |
