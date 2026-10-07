# 07 — Site 1 (résidence) : câblage et affectation des ports

Matériel : box Yas → **hAP ax³** (routeur) → **HPE 1920-8G-PoE+ JG921A** (switch cœur).

## hAP ax³

| Port | Rôle | Mode |
|---|---|---|
| ether1 (2,5 GbE) | WAN → box Yas (`192.168.1.2`, en DMZ) | routé, hors bridge |
| ether2 | Trunk → HPE 1920 port 5 | tagged 10,20,30,40,50,60,70,80 |
| ether3 | Proxmox Ryzen | trunk tagged 10,20,50 (VM sur plusieurs VLAN) |
| ether4 | Poste d'administration | access VLAN 10 |
| ether5 | Réserve / dépannage | access VLAN 10 |
| Wi-Fi 5 GHz + 2,4 GHz | SSID maison → 30, SSID IoT (2,4 GHz) → 40, SSID invités → 60 | VLAN par SSID |

## HPE 1920-8G-PoE+ (JG921A)

| Port | PoE+ | Équipement | Mode |
|---|---|---|---|
| 1 | ✅ | Caméra (ou cAP ax plus tard) | access VLAN 50 |
| 2 | ✅ | Caméra | access VLAN 50 |
| 3 | ✅ | Caméra | access VLAN 50 |
| 4 | ✅ | Caméra | access VLAN 50 |
| 5 | — | Trunk ← hAP ax³ ether2 | tagged tous VLAN |
| 6 | — | MANTBox (via son injecteur) | access VLAN 70 |
| 7 | — | NanoBeam (via son injecteur) | **hybrid** : 80 non tagué (trafic des proches, aucune config sur les CPE) + 10 tagué (management des radios) |
| 8 | — | Proxmox Dell | trunk tagged 10,20 |
| SFP 1 | — | Module SFP→RJ45 1000BASE-T → switch PoE TP-Link (autres caméras) | access VLAN 50 |
| SFP 2 | — | Module SFP→RJ45 → switch TP-Link (postes filaires) | access VLAN 30 |

Management du switch : IP `10.1.10.2` sur le VLAN 10 uniquement.

## Points d'attention

- **Ne jamais brancher une radio Ubiquiti/MikroTik en PoE passif 24 V directement sur
  un port PoE+ 802.3at**, ni l'inverse. Les NanoBeam, LiteAP, Loco et la MANTBox gardent leurs
  injecteurs et vont sur les ports 6–8, qui ne sont pas PoE.
- **Budget PoE de 65 W** sur 4 ports : 4 caméras à environ 5–8 W chacune, c'est large ; un cAP ax
  consomme environ 15 W au maximum.
- Les switchs TP-Link non administrables ne portent **qu'un seul VLAN** chacun (port access).
  Ne jamais les mettre sur un trunk.
- Total de 10 ports : c'est juste pour la résidence. Si besoin plus tard, un second switch VLAN
  (ex. CSS610-8P-2S+) sur le port SFP 1 en trunk.
