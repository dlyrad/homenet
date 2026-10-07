# 06 — Plan de migration

Chaque phase est réversible et laisse le réseau existant fonctionnel.

## Phase 0 — Inventaire et mesures
- [ ] Recenser chaque équipement (site, emplacement, MAC, IP actuelle, usage) → NetBox.
- [x] Vérifier le CGNAT : les box ont une IP publique (dynamique) → tunnels directs possibles.
- [ ] Vérifier que chaque box accepte une **DMZ** ou une redirection UDP.
- [ ] Mesurer la latence depuis chaque site vers des VPS candidats (Paris, Marseille, Francfort…).
- [ ] Avec **ONVIF Device Manager**, relever pour 2–3 caméras l'URL RTSP, le codec (H.264/H.265), la résolution et le débit des flux principal et secondaire.
- [ ] Relever le nombre de caméras par site, et la capacité disque et la compatibilité ONVIF des NVR.
- [ ] Cartographier le partage de connexion : position du point relais, nombre de proches et de clients du hotspot, modèles des CPE.

## Phase 1 — Hub et lab
- [ ] Louer le VPS, installer CHR (ou Debian + WireGuard + FRR), durcir (SSH clé, pare-feu).
- [ ] Monter un RB941 en lab avec la config type d'un site ; valider tunnel + OSPF + pare-feu.
- [ ] VPN nomade (téléphone/PC) vers le hub.

## Phase 2 — Site 1 (résidence)
- [ ] Installer le routeur (hAP ax³ à la résidence, RB5009 au bureau) derrière la box (DMZ si possible), VLAN, DHCP, DNS, pare-feu par zone.
- [ ] **Priorité** : basculer la MANTBox sur le VLAN 70 et la NanoBeam/le relais sur le VLAN 80 + QoS — les tiers sortent du réseau de la maison.
- [ ] Switch PoE VLAN ; migration **VLAN par VLAN** : ADMIN → SERV → USERS → IOT → CAM → GUEST.
- [ ] Tunnel vers le hub ; supervision de base (Uptime Kuma sur VPS).

## Phase 3 — Site 2 (bureau)
- [ ] Même config type (seul l'ID de site change).
- [ ] Tunnel WireGuard direct résidence ↔ bureau (IP Cloud + script de mise à jour de l'endpoint).
- [ ] OSPF : vérifier que `10.1.0.0/16` et `10.2.0.0/16` se voient ; tester la bascule via le hub.

## Phase 4 — Vidéo et supervision
- [ ] Couper Internet au VLAN CAM ; vérifier que les flux RTSP/ONVIF fonctionnent toujours.
- [ ] Frigate résidence (Ryzen) et bureau (Dell) : caméras locales enregistrées, caméras distantes en sous-flux.
- [ ] Accès distant aux caméras par le VPN nomade (téléphone).
- [ ] Zabbix/Grafana/NetBox/Loki ; alertes Telegram.
- [ ] Onduleurs + NUT.

## Phase 5 — Industrialisation
- [ ] Config type de site versionnée dans ce dépôt (`configs/site-template.rsc`, sans secrets).
- [ ] Procédure « ajouter un site » (≤ 1 h).
- [ ] Sauvegardes automatiques des configs RouterOS et des VM Proxmox (réplication croisée entre sites).
