# 06 — Plan de migration

Chaque phase est réversible et laisse le réseau existant fonctionnel.

## Phase 0 — Inventaire et mesures
- [ ] Recenser chaque équipement (site, emplacement, MAC, IP actuelle, usage) → NetBox.
- [ ] Vérifier CGNAT sur chaque box (IP WAN de la box ≠ IP vue sur un site « what is my IP » → CGNAT).
- [ ] Mesurer latence depuis chaque site vers des VPS candidats (Paris, Marseille, Francfort…).
- [ ] Tester sur 2–3 caméras l'accès **RTSP/ONVIF** local (VLC, ONVIF Device Manager).

## Phase 1 — Hub et lab
- [ ] Louer le VPS, installer CHR (ou Debian + WireGuard + FRR), durcir (SSH clé, pare-feu).
- [ ] Monter un RB941 en lab avec la config type d'un site ; valider tunnel + OSPF + pare-feu.
- [ ] VPN nomade (téléphone/PC) vers le hub.

## Phase 2 — Site 1 (résidence)
- [ ] Installer le RB5009 derrière la box (DMZ si possible), VLAN, DHCP, DNS, pare-feu par zone.
- [ ] Switch PoE VLAN ; migration **VLAN par VLAN** : ADMIN → SERV → USERS → IOT → CAM → GUEST.
- [ ] Tunnel vers le hub ; supervision de base (Uptime Kuma sur VPS).

## Phase 3 — Site 2 (bureau)
- [ ] Même config type (seul l'ID de site change).
- [ ] OSPF : vérifier que `10.1.0.0/16` et `10.2.0.0/16` se voient via le hub.
- [ ] Tunnel direct opportuniste si l'un des sites est joignable.

## Phase 4 — Vidéo et supervision
- [ ] Frigate sur le Ryzen : caméras locales en flux principal, distantes en sous-flux.
- [ ] Zabbix/Grafana/NetBox/Loki ; alertes Telegram.
- [ ] Onduleurs + NUT.

## Phase 5 — Industrialisation
- [ ] Config type de site versionnée dans ce dépôt (`configs/site-template.rsc`, sans secrets).
- [ ] Procédure « ajouter un site » (≤ 1 h).
- [ ] Sauvegardes automatiques des configs RouterOS et des VM Proxmox (réplication croisée entre sites).
