# 03 — Plan d'adressage

## Convention

`10.<site>.<vlan>.0/24` — le 2e octet identifie le site, le 3e le VLAN.
Chaque site dispose d'un `/16` résumable (une seule route OSPF par site).

| Site | ID | Préfixe |
|---|---|---|
| Résidence | 1 | `10.1.0.0/16` |
| Bureau | 2 | `10.2.0.0/16` |
| Futurs sites | 3–99 | `10.N.0.0/16` |
| Accès nomades (VPN) | 200 | `10.200.0.0/24` |
| Tunnels / loopbacks | 255 | `10.255.0.0/16` |

## VLAN (identiques sur tous les sites)

| VLAN | Nom | Sous-réseau (site N) | Passerelle | DHCP |
|---|---|---|---|---|
| 10 | ADMIN | `10.N.10.0/24` | `.1` | IP fixes ; petite plage `.200–.219` pour le dépannage |
| 20 | SERV | `10.N.20.0/24` | `.1` | Réservations |
| 30 | USERS | `10.N.30.0/24` | `.1` | `.100–.250` |
| 40 | IOT | `10.N.40.0/24` | `.1` | `.50–.250` |
| 50 | CAM | `10.N.50.0/24` | `.1` | Réservations |
| 60 | GUEST | `10.N.60.0/24` | `.1` | `.50–.250`, isolé |
| 70 | HOTSPOT | `10.N.70.0/23` | `.1` | `10.N.70.10`–`10.N.71.250`, portail captif, isolé |
| 80 | RELAIS | `10.N.80.0/24` — **site 1 : `192.168.20.0/24`** (voir ci-dessous) | `.1` (site 1 : `.5`) | Réservations par CPE de proche, isolé |

**Exception site 1 — RELAIS** : on conserve le réseau actuel des proches, `192.168.20.0/24`
(passerelle `192.168.20.5`, l'ancienne adresse du routeur Xiaomi). La bascule se fait ainsi
sans rien reconfigurer chez eux. Ce VLAN ne sort jamais du site et n'est jamais routé vers
les autres sites, donc pas de conflit possible. Renumérotation en `10.1.80.0/24` plus tard,
si besoin.

Les VLAN 70 et 80 n'existent aujourd'hui qu'à la résidence. HOTSPOT est un `/23` pour
accueillir plus de 250 clients.

Le lien box FAI ↔ routeur reste sur le LAN de la box : `192.168.1.0/24` sur **les deux
sites**. C'est sans conséquence, car ce réseau n'est pas routé entre les sites. **Ne jamais
réutiliser** `192.168.0.0/16` en interne. Le MikroTik prend une IP fixe (ex. `192.168.1.2`,
hors du DHCP de la box) et est placé en **DMZ** de la box.

Passerelles des box : résidence (Yas/Togocom) = `192.168.1.254` ; bureau (Canalbox) = à relever.

## Tunnels

| Tunnel | Sous-réseau | Extrémités |
|---|---|---|
| Résidence ↔ Bureau (direct, principal) | `10.255.1.8/30` | site 1 `.9`, site 2 `.10` |
| Hub ↔ Résidence (secours) | `10.255.0.4/30` | hub `.5`, site `.6` |
| Hub ↔ Bureau (secours) | `10.255.0.8/30` | hub `.9`, site `.10` |
| Loopback routeur site N | `10.255.255.N/32` | identifiant OSPF (router-id) |

Conventions (sans collision jusqu'à 63 sites) :
- hub ↔ site N → `10.255.0.(4×N)/30` (hub = 1re IP, site = 2e) ;
- direct site A ↔ site B (A < B) → `10.255.A.(4×B)/30` (A = 1re IP, B = 2e).

| Port WireGuard | Usage |
|---|---|
| UDP 13231 | Tunnels inter-sites (DMZ ou redirection sur la box) |
| UDP 13232 | Accès nomades (sur le hub) |

## Adresses réservées dans chaque VLAN

| Plage | Usage |
|---|---|
| `.1` | Passerelle (routeur du site) |
| `.2–.9` | Switchs, AP (dans ADMIN) / infra |
| `.10–.49` | Serveurs, NVR, caméras (IP fixes/réservées) |
| `.50–.250` | DHCP dynamique |

## Nommage

`<site>-<type>-<nn>` avec site = `res`, `bur`, … ; type = `rtr`, `sw`, `ap`, `pve`,
`nvr`, `cam`, `ups`, `ptp` (radio point-à-point), `sec` (secteur radio), `cpe`. Ex. `res-rtr-01`, `bur-cam-07`. Domaine DNS interne :
`<site>.home.arpa` (ex. `bur-cam-07.bur.home.arpa`).
