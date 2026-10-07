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
| 1 | ✅ | Caméra PoE actuelle | access VLAN 50 |
| 2 | ✅ | **Switch actuel de la maison** (PC, imprimante, TV) — le PoE ne gêne pas un appareil non PoE | access VLAN 30 |
| 3 | ✅ | Caméra / switch TP-Link de caméras (plus tard) | access VLAN 50 |
| 4 | ✅ | Test du hotspot, puis futur AP du hotspot | access VLAN 70 |
| 5 | — | Trunk ← hAP ax³ ether2 | tagged tous VLAN |
| 6 | — | MANTBox (via son injecteur) | **étape A** : access VLAN 80 (comme aujourd'hui, derrière le Xiaomi) → **étape B** : access VLAN 70 |
| 7 | — | NanoBeam (via son injecteur) | **hybrid** : 80 non tagué (trafic des proches, aucune config sur les CPE) + 10 tagué (management des radios) |
| 8 | — | Proxmox Dell (aujourd'hui sur le switch de la maison) | trunk tagged 10,20 |
| SFP 1–2 | — | Libres (pas de module pour l'instant) | désactivés |

Management du switch : IP `10.1.10.2` sur le VLAN 10 uniquement.

## Points d'attention

- Les radios (NanoBeam, LiteAP, Loco, MANTBox) s'alimentent en **PoE passif 24 V** : un port
  PoE+ 802.3at ne les alimentera pas. Elles gardent donc leurs injecteurs et vont sur les ports
  6–8, qui ne sont pas PoE. **Ne jamais relier la sortie PoE d'un injecteur passif à un port
  PoE+.**
- **Budget PoE de 65 W** sur 4 ports : 4 caméras à environ 5–8 W chacune, c'est large ; un cAP ax
  consomme environ 15 W au maximum.
- Les switchs TP-Link non administrables ne portent **qu'un seul VLAN** chacun (port access).
  Ne jamais les mettre sur un trunk.
- Sans module SFP, il reste **8 ports** : tout est occupé sauf le port 3. Extension possible :
  modules SFP→RJ45 (~15 € pièce), ou un second switch VLAN en trunk.
