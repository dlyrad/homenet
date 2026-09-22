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
| Stockage vidéo | Disque(s) de surveillance 2–4 To pour le Ryzen (Frigate) | selon rétention |

## Réutilisation de l'existant

| Équipement | Nouveau rôle |
|---|---|
| TL-SG1008M (×5) | Switchs d'extrémité **mono-VLAN** branchés sur un port *access* (ex. un groupe de caméras non-PoE, un bureau) |
| RB941 hAP lite (×2) | Lab de test des configs ; ou routeur d'un petit site futur ; ou routeur 4G de secours avec clé USB |
| MANTBox / NanoBeam / LiteAP AC / Loco AC | Liaisons radio (à confirmer : existe-t-il une liaison radio entre bâtiments / vers un site proche ?) — elles transportent alors un trunk VLAN |
| ASUS RT-AC5300 | AP transitoire pendant la migration, puis retrait |
| Netgear R6220, Xiaomi, Tenda | Retrait (pas de VLAN par SSID, firmwares fermés) |
| Proxmox Dell (×2) | Un par site : DNS interne, contrôleur/exporters, sauvegardes croisées |
| Ryzen AI 9 HX470 | Proxmox : **Frigate** (détection accélérée iGPU/NPU) + **supervision centrale** |

> Priorité d'achat si budget étalé : 1) RB5009 résidence + VPS, 2) RB5009 bureau,
> 3) switchs PoE VLAN, 4) onduleurs, 5) AP cAP ax, 6) secours 4G.
