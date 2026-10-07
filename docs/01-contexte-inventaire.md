# 01 — Contexte et inventaire

## Accès Internet

| Site | Opérateur | Descendant | Montant | IPv4 publique | Box en bridge |
|---|---|---|---|---|---|
| Résidence | Yas (Togocom) | ~200 Mb/s | 10–50 Mb/s | **Oui, sur la box** (pas de CGNAT), mais dynamique | Possible mais **pas d'identifiants PPPoE** fournis |
| Bureau | Canalbox | ~200 Mb/s | 10–50 Mb/s | **Oui, sur la box** (pas de CGNAT), mais dynamique | Méthode inconnue (portail captif ?) |

LAN des deux box : `192.168.1.0/24`. Ce n'est pas gênant : ce réseau sert uniquement de
transit entre la box et le MikroTik et n'est jamais routé entre les sites.

### Conséquences sur l'architecture

- On **garde la box FAI comme routeur** (NAT) et on place notre routeur MikroTik
  derrière elle (double NAT assumé). Pas de dépendance au mode bridge.
- Pas de CGNAT : avec une **DMZ** (ou une redirection UDP) de la box vers le MikroTik,
  chaque site est joignable depuis Internet → **tunnels WireGuard directs entre sites**,
  avec un nom DDNS (MikroTik *IP Cloud*) pour suivre les changements d'IP.
- Les IP changent sans préavis → un **VPS à IP fixe** reste utile comme point de
  rendez-vous de secours, pour les accès nomades et pour les futurs sites en 4G (souvent
  derrière du CGNAT).
- Montant limité (10–50 Mb/s) → les flux vidéo inter-sites passent en **sous-flux**
  (substream) ; l'enregistrement principal reste local à chaque site.

## Inventaire matériel existant

| Équipement | Qté | Évaluation | Rôle envisagé |
|---|---|---|---|
| ASUS RT-AC5300 | 1 | Bon Wi-Fi, VLAN limités | Point d'accès (mode AP) transitoire, puis retrait |
| Netgear R6220 | 2 | Faible | Retrait (ou AP invités transitoire) |
| MikroTik **hAP ax³** (C53UiG+5HPaxD2HPaxD) | 1 | 4 cœurs ARM64 1,8 GHz, 1 Go RAM, 1× 2,5 GbE + 4× GbE, Wi-Fi 6, USB 3, RouterOS v7 | **Routeur / pare-feu de la résidence** + Wi-Fi + contrôleur CAPsMAN |
| **HPE OfficeConnect 1920-8G-PoE+ (65 W) — JG921A** | 1 | 8 ports GbE (dont 4 PoE+, budget 65 W) + 2 SFP 1 Gb ; switch *smart* administrable : 802.1Q (VLAN), LACP, SNMP v3, LLDP, QoS, miroir de port ; firmware Comware, en fin de vie | **Switch cœur VLAN de la résidence** |
| MikroTik RB941-2nD (hAP lite) | 2 | CPU faible, ports 100 Mb/s | Lab / petit site secondaire / LTE de secours |
| Points d'accès Tenda | ? | Pas de VLAN par SSID | Retrait progressif |
| TP-Link TL-SG1008M (non administrable) | 5 | OK en switch de bord mono-VLAN | Switch d'extrémité (ex. grappe de caméras sur un port *access*) |
| Routeurs Xiaomi | ? | Firmware fermé | Retrait |
| MikroTik MANTBox | 1 | Radio extérieure | **Hotspot / portail captif** pour des clients |
| Ubiquiti NanoBeam | 1 | Radio point-à-point | **Pont** résidence → point relais |
| Ubiquiti LiteAP AC | 1 | Secteur point-multipoint | **Point d'accès** au point relais pour les proches |
| Ubiquiti Loco AC | 2 | Radio | Point d'accès au relais (1) ; usage de la 2e à préciser |
| Mini-serveur Dell Xeon 7e gén., 16 Go, 1 To SSD, Proxmox | 2 | 1 résidence, 1 bureau | Services d'infra par site |
| Mini-serveur Ryzen AI 9 HX470, 32 Go DDR5, 1 To NVMe | 1 | Puissant, iGPU/NPU | NVR intelligent (Frigate) + supervision centrale |
| Caméras IP chinoises (Tuya/Smart Life) | ~15 | **ONVIF** → flux RTSP local exploitable | VLAN caméras **sans Internet** |
| NVR sans marque (Tuya/Smart Life) | ≥2 | Capacité disque à vérifier | Enregistrement 24/7 local, ou remplacés par Frigate |
| Objets connectés Tuya / Google Assistant | ? | Dépendants du cloud | VLAN IoT |

## Topologie actuelle de la résidence (relevé du 2026-10-07)

```
Box Togocom/Yas 192.168.1.254  (LAN 192.168.1.0/24)
 ├── Switch non administrable
 │     ├── PC d'administration      192.168.1.66
 │     ├── Imprimante
 │     ├── Télévision
 │     ├── Serveur Dell (Proxmox)
 │     └── hAP ax³ (branché pour préparation)
 ├── Routeur Xiaomi  → LAN 192.168.20.0/24 (192.168.20.5)
 │     └── NanoBeam ···radio··· point relais (LiteAP AC, Loco AC) ··· CPE des proches (192.168.20.x)
 ├── Routeur Netgear R6220 → LAN 10.0.0.0/24 (10.0.0.1)
 │     └── HPE 1920-8G-PoE+ → 1 caméra PoE
 └── MANTBox (hotspot) : emplacement à préciser
```

Constats :
- Proches et caméra sont derrière un **NAT** (Xiaomi, Netgear) : ils ne sont pas joignables
  depuis la maison, **mais eux peuvent joindre `192.168.1.x`** (PC, Dell, imprimante, TV),
  car pour le Xiaomi et le Netgear, ce réseau est simplement « l'extérieur ». C'est le risque n° 1.
- Triple NAT pour les proches et la caméra, trois routeurs à administrer séparément, aucune
  supervision centralisée.
- Cible : le hAP ax³ remplace la box comme routeur interne, et le Xiaomi et le Netgear disparaissent.
  Le réseau des proches `192.168.20.0/24` est **conservé** dans le VLAN 80 (bascule sans
  intervention chez eux).
- Le hAP ax³ **sorti de carton** a une configuration par défaut avec un serveur DHCP
  `192.168.88.x` sur ether2–5 : **ne jamais le relier au switch de la maison par ether2–5**
  avant la remise à zéro (il distribuerait de mauvaises adresses à tout le réseau).

Il n'y a pas de liaison radio résidence ↔ bureau (obstacles) : l'interconnexion passe
uniquement par Internet.

> À compléter : quantités exactes, emplacement de chaque équipement, nombre de caméras
> par site (voir [questions-ouvertes.md](questions-ouvertes.md)).
