# 01 — Contexte et inventaire

## Accès Internet

| Site | Opérateur | Descendant | Montant | IPv4 publique | Box en bridge |
|---|---|---|---|---|---|
| Résidence | Yas (Togocom) | ~200 Mb/s | 10–50 Mb/s | Non garantie / change | Possible mais **pas d'identifiants PPPoE** fournis |
| Bureau | Canalbox | ~200 Mb/s | 10–50 Mb/s | Non garantie / change | Méthode inconnue (portail captif ?) |

### Conséquences sur l'architecture

- On **garde la box FAI comme routeur** (NAT) et on place notre routeur MikroTik
  derrière elle (double NAT assumé). Pas de dépendance au mode bridge.
- Adresses publiques instables, voire CGNAT → **on ne compte sur aucune connexion
  entrante**. Chaque site **initie** son tunnel vers un point fixe : un **VPS avec IP
  publique fixe** (hub).
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
| MikroTik MANTBox | 1 | Radio extérieure 5 GHz | Liaison radio / Wi-Fi extérieur (à préciser) |
| Ubiquiti NanoBeam | 1 | Radio point-à-point | Liaison PtP (à préciser) |
| Ubiquiti LiteAP AC | 1 | Secteur point-multipoint | Liaison PtMP (à préciser) |
| Ubiquiti LocoM/Loco AC | 2 | Client radio | Liaison PtP (à préciser) |
| Mini-serveur Dell Xeon 7e gén., 16 Go, 1 To SSD, Proxmox | 2 | 1 résidence, 1 bureau | Services d'infra par site |
| Mini-serveur Ryzen AI 9 HX470, 32 Go DDR5, 1 To NVMe | 1 | Puissant, iGPU/NPU | NVR intelligent (Frigate) + supervision centrale |
| Caméras IP chinoises (Tuya/Smart Life) | ~15 | Cloud Tuya, RTSP/ONVIF à vérifier | VLAN caméras |
| NVR sans marque (Tuya/Smart Life) | ≥2 | À évaluer | Conservés ou remplacés par Frigate |
| Objets connectés Tuya / Google Assistant | ? | Dépendants du cloud | VLAN IoT |

> À compléter : quantités exactes, emplacement de chaque équipement, et usage actuel des
> radios Ubiquiti / MANTBox (voir [questions-ouvertes.md](questions-ouvertes.md)).
