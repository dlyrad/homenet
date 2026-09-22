# 05 — Supervision

## Principe

- **Collecte centrale** sur le serveur Ryzen (résidence), qui joint tous les sites via
  le réseau unifié.
- **Sonde externe** sur le VPS : surveille les sites *et* le serveur central, pour
  être alerté même quand la résidence est hors ligne (coupure courant/Internet).

## Stack

| Outil | Où | Rôle |
|---|---|---|
| **Zabbix** (ou LibreNMS) | VM Proxmox Ryzen | SNMP v3 sur MikroTik/switchs/onduleurs, agent sur Proxmox/VM, ping ICMP de chaque caméra/objet, découverte automatique par sous-réseau |
| **Grafana** | même VM | Tableaux de bord : débit WAN par site, latence tunnels, état caméras |
| **Uptime Kuma** | VPS | Disponibilité vue de l'extérieur (tunnels, NVR, services) ; alertes Telegram |
| **NetBox** | VM Proxmox | Source de vérité : sites, baies, équipements, IP, VLAN, câblage |
| **Loki + Promtail** (ou Graylog) | VM Proxmox | Journaux syslog des routeurs (pare-feu, WireGuard, DHCP) |
| **NUT** | Proxmox de chaque site | État des onduleurs, arrêt propre des serveurs |

## Indicateurs clés

- Par site : lien WAN (up/down, débit, IP publique actuelle), état tunnel(s) WireGuard
  (dernier handshake), voisinage OSPF, latence/perte vers le hub.
- Par équipement : joignabilité, CPU/RAM/température (routeurs, serveurs), ports switch
  (up/down, erreurs, PoE consommé).
- Caméras : ping + test de flux RTSP ; espace disque NVR/Frigate.
- Électricité : passage sur batterie, autonomie restante.

## Alertes

Canal principal **Telegram** (bot), secondaire e-mail. Niveaux : critique (site/tunnel
down, onduleur sur batterie), avertissement (caméra down > 10 min, disque > 85 %).
