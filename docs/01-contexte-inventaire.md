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

## Partage de connexion existant (résidence)

```
Box Yas ── réseau résidence ──┬── MANTBox ··· clients du hotspot (portail captif)
                              └── NanoBeam ···radio··· point relais
                                                       ├── LiteAP AC ··· LiteBeam/Loco des proches
                                                       └── Loco AC   ··· LiteBeam/Loco des proches
```

Constat : ces utilisateurs **externes** partagent aujourd'hui, très probablement, le même
réseau que les équipements de la maison (serveurs, caméras). C'est le premier risque à
corriger (voir [02-architecture.md](02-architecture.md), zones HOTSPOT et RELAIS).

Il n'y a pas de liaison radio résidence ↔ bureau (obstacles) : l'interconnexion passe
uniquement par Internet.

> À compléter : quantités exactes, emplacement de chaque équipement, nombre de caméras
> par site (voir [questions-ouvertes.md](questions-ouvertes.md)).
