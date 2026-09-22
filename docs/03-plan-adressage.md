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
| 10 | ADMIN | `10.N.10.0/24` | `.1` | Non (IP fixes) |
| 20 | SERV | `10.N.20.0/24` | `.1` | Réservations |
| 30 | USERS | `10.N.30.0/24` | `.1` | `.100–.250` |
| 40 | IOT | `10.N.40.0/24` | `.1` | `.50–.250` |
| 50 | CAM | `10.N.50.0/24` | `.1` | Réservations |
| 60 | GUEST | `10.N.60.0/24` | `.1` | `.50–.250`, isolé |

Le lien box FAI ↔ routeur reste sur le LAN de la box (ex. `192.168.1.0/24` Canalbox,
selon box) : **ne jamais réutiliser** ces plages en interne. Mettre si possible
l'adresse du MikroTik en **DMZ** de la box (améliore le NAT pour WireGuard).

## Tunnels

| Tunnel | Sous-réseau | Extrémités |
|---|---|---|
| Hub ↔ Résidence | `10.255.1.0/30` | hub `.1`, site `.2` |
| Hub ↔ Bureau | `10.255.2.0/30` | hub `.1`, site `.2` |
| Résidence ↔ Bureau (direct) | `10.255.12.0/30` | site1 `.1`, site2 `.2` |
| Loopback routeur site N | `10.255.255.N/32` | identifiant OSPF |

## Adresses réservées dans chaque VLAN

| Plage | Usage |
|---|---|
| `.1` | Passerelle (routeur du site) |
| `.2–.9` | Switchs, AP (dans ADMIN) / infra |
| `.10–.49` | Serveurs, NVR, caméras (IP fixes/réservées) |
| `.50–.250` | DHCP dynamique |

## Nommage

`<site>-<type>-<nn>` avec site = `res`, `bur`, … ; type = `rtr`, `sw`, `ap`, `pve`,
`nvr`, `cam`, `ups`. Ex. `res-rtr-01`, `bur-cam-07`. Domaine DNS interne :
`<site>.home.arpa` (ex. `bur-cam-07.bur.home.arpa`).
