# 04 — Matériel

Choix : **MikroTik** comme socle (routage, pare-feu, WireGuard, OSPF, EoIP, CAPsMAN,
supervision SNMP) — une seule syntaxe (RouterOS v7) sur tous les sites et le hub.

## À acquérir — par site

| Rôle | Recommandé | Alternative économique | Pourquoi |
|---|---|---|---|
| Routeur / pare-feu | **RB5009UG+S+IN** | hEX S (RB760iGS) | WireGuard à plusieurs centaines de Mb/s, 8 ports Gb + SFP+, marge pour VLAN/pare-feu |
| Switch cœur PoE (caméras + AP) | **CRS328-24P-4S+RM** (24 PoE) | CSS610-8P-2S+IN (8 PoE) ou netPower 16P | VLAN 802.1Q + PoE pour caméras et AP |
| Point(s) d'accès Wi-Fi | **cAP ax** (plafond) | cAP ac | SSID multiples → VLAN (USERS, IOT, GUEST), gestion centralisée CAPsMAN |
| Onduleur | 1000–1500 VA line-interactive avec port USB/SNMP | — | Coupures électriques ; supervision via NUT |
| Secours 4G (option) | **LtAP mini LTE** ou Chateau LTE | hAP lite + clé 4G | Route de secours si la box tombe |

## À acquérir — central

| Rôle | Recommandé | Coût indicatif |
|---|---|---|
| VPS hub | 1 vCPU / 1–2 Go RAM, IP v4 fixe, Europe de l'Ouest | ~4–6 €/mois |
| Licence MikroTik CHR | P1 (1 Gb/s) | ~45 $ une fois (ou Debian + WireGuard, gratuit) |
| Stockage vidéo | Voir « Stockage vidéo » ci-dessous | selon nombre de caméras par site |

## Réutilisation de l'existant

| Équipement | Nouveau rôle |
|---|---|
| TL-SG1008M (×5) | Switchs d'extrémité **mono-VLAN** branchés sur un port *access* (ex. un groupe de caméras non-PoE, un bureau) |
| RB941 hAP lite (×2) | Lab de test des configs ; ou routeur d'un petit site futur ; ou routeur 4G de secours avec clé USB |
| MANTBox | AP du hotspot sur le VLAN 70 (portail sur le RB5009) |
| NanoBeam → LiteAP AC + Loco AC | Pont radio vers le point relais, qui transporte VLAN 80 (proches) + VLAN de management (ADMIN) |
| ASUS RT-AC5300 | AP transitoire pendant la migration, puis retrait |
| Netgear R6220, Xiaomi, Tenda | Retrait (pas de VLAN par SSID, firmwares fermés) |
| Proxmox Dell (×2) | Un par site : DNS interne, sauvegardes croisées ; celui du bureau fait aussi tourner Frigate (bureau) |
| Ryzen AI 9 HX470 | Proxmox : **Frigate** (détection accélérée iGPU/NPU) + **supervision centrale** |

## Stockage vidéo (rétention 3 semaines)

Les mini-serveurs n'acceptent en général pas de disques 3,5". On ajoute donc par site :

| Option | Matériel | Remarque |
|---|---|---|
| **A (recommandée)** | Boîtier DAS USB 3 / USB-C 2 baies + 2 disques **surveillance** (WD Purple / Seagate SkyHawk) de 8 To | Monté dans Proxmox, dédié à Frigate |
| B | Réutiliser les disques des NVR existants (s'ils en ont) | Capacité souvent faible (1–4 To) |
| C | NAS 2 baies (partage NFS) | Plus cher, mais mutualisable pour les sauvegardes |

Taille à ajuster selon le nombre de caméras par site (voir le calcul dans
[02-architecture.md](02-architecture.md) §6) : ~0,5–1 To par caméra pour 21 jours en
continu, beaucoup moins en mode « continu sous-flux + événements en flux principal ».

Détection Frigate au bureau : si le Xeon du Dell n'a pas d'iGPU → **Coral USB TPU**
(~60 €) ou **Hailo-8L**.

## Priorités d'achat (budget étalé)

1. RB5009 résidence : il permet tout de suite d'**isoler hotspot et proches** (risque n° 1).
2. Switch PoE VLAN résidence + disques vidéo résidence.
3. RB5009 bureau, switch PoE VLAN bureau, disques vidéo bureau.
4. Onduleurs.
5. VPS hub (secours + nomades).
6. AP cAP ax, secours 4G.
