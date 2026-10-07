# 08 — Procédure site 1 : préparation sur table puis bascule

Matériel : hAP ax³ (RouterOS 7.23.7 long-term) + HPE 1920-8G-PoE+ (JG921A).
Rien n'est en production : on configure **sur table**, puis on bascule en une fois.
L'ancien routeur reste à portée de main pour un retour arrière.

Il faut un PC avec **WinBox 4** et un navigateur, et 3 câbles réseau.

## Étape 0 — Câblage de préparation (sans gêner la maison)

> ⚠️ Le hAP ax³ sorti de carton fait serveur DHCP `192.168.88.x` sur ether2–5. S'il est
> branché au switch de la maison par l'un de ces ports, **le débrancher tout de suite**
> (les appareils de la maison risquent de recevoir une mauvaise adresse). Si un appareil a
> déjà reçu une adresse `192.168.88.x`, le débrancher puis le rebrancher.

```
Switch de la maison ──── ether1 (WAN) hAP ax³ ether4 ──── PC d'administration
   (192.168.1.x)          192.168.1.2                    (10.1.10.2xx, Internet via le hAP)
```

- **ether1** du hAP ax³ → switch de la maison : il sort sur Internet par la box (`192.168.1.254`).
- **PC** → **ether4** du hAP ax³ : il garde Internet (via le hAP) pendant toute la préparation.
- Avant l'import : vérifier que **`192.168.1.2` est libre** (`ping 192.168.1.2` depuis le PC,
  et la page DHCP de la box) et hors de la plage DHCP de la box ; sinon, changer l'adresse
  dans le script.

## Étape 1 — hAP ax³

1. Brancher le PC sur **ether4**, ouvrir WinBox, se connecter par **adresse MAC**.
2. **System → Packages → Check for updates** : rester sur le canal *long-term* (7.23.x) ;
   vérifier que le paquet `wifi-qcom` est présent. **System → RouterBOARD → Upgrade**
   (firmware), puis redémarrer.
3. Réinitialiser à blanc : `/system reset-configuration no-defaults=yes skip-backup=yes`.
4. Reconnexion par MAC, glisser `configs/res-rtr-01.rsc` dans **Files**, puis, dans le
   terminal : `/import file-name=res-rtr-01.rsc verbose=yes`.
   - La session peut couper à la dernière ligne (activation du filtrage VLAN) : c'est normal.
   - Le PC (sur ether4) reçoit une adresse `10.1.10.2xx` → se reconnecter sur **10.1.10.1**.
   - En cas d'erreur, `verbose=yes` affiche la ligne fautive : la noter et me la transmettre.
5. Copier `res-rtr-01.secrets.rsc.example` en `res-rtr-01.secrets.rsc`, remplacer les `<...>`,
   l'importer, puis le supprimer du routeur (voir l'en-tête du fichier).
6. Se reconnecter avec le nouveau compte, puis `/user remove admin`.
7. Sauvegarde : `/system backup save name=res-rtr-01-j0` et `/export file=res-rtr-01-j0`
   → récupérer les deux fichiers sur le PC (jamais dans Git : l'export peut contenir des secrets).

## Étape 2 — HPE 1920 (interface web)

1. Retirer le HPE de derrière le Netgear (la caméra PoE sera coupée le temps de la configuration).
   Relier le **port 5** du switch à **ether5** du hAP ax³ (accès ADMIN, provisoirement).
   Le switch est client DHCP par défaut : son IP apparaît dans
   **IP → DHCP Server → Leases** du hAP ax³ (`10.1.10.2xx`).
2. Navigateur → `http://10.1.10.2xx` → compte `admin`, mot de passe vide (par défaut).
3. **Device → Device Maintenance → Software Upgrade** : dernier firmware disponible.
4. **Network → VLAN → Create** : `10,20,30,40,50,60,70,80` ; nommer chaque VLAN
   (ADMIN, SERV, USERS, IOT, CAM, GUEST, HOTSPOT, RELAIS).
5. **Network → VLAN Interface → Create** : VLAN 10, IP statique `10.1.10.2/24`.
   **Network → IPv4 Routing → Create** : `0.0.0.0/0` via `10.1.10.1`.
6. **Network → VLAN → Modify Port**, selon [07-site1-cablage.md](07-site1-cablage.md) :

   | Port | Type | PVID | Non tagué | Tagué |
   |---|---|---|---|---|
   | 1–4 | Access | 50 | 50 | — |
   | 6 | Access | 70 | 70 | — |
   | 7 | **Hybrid** | 80 | 80 | 10 |
   | 8 | Trunk | 1 | — | 10, 20 |
   | SFP 1 (9) | Access | 50 | 50 | — |
   | SFP 2 (10) | Access | 30 | 30 | — |
   | **5 (en dernier)** | Trunk | 1 | — | 10–80 |

   Retirer le VLAN 1 non tagué des ports *hybrid*. Au passage du port 5 en trunk, la
   connexion coupe : **déplacer le câble du port 5 de ether5 vers ether2** du hAP ax³ et
   rejoindre le switch sur `10.1.10.2` (PC toujours sur ether4).
7. Retirer l'adresse de **Vlan-interface 1** (management uniquement par VLAN 10).
8. **Device → Users** : mot de passe admin fort. **Device → SNMP** : v3 uniquement,
   accès depuis `10.1.20.0/24`. **Network → LLDP** : activé. Désactiver les ports inutilisés.
9. **Enregistrer** (bouton *Save* en haut à droite) : sans cela, tout est perdu au redémarrage.

> Ports SFP : modules **1000BASE-T (SFP → RJ45)** ; préférer un modèle compatible HPE
> (ex. JD089B ou équivalent codé HPE), certains modules génériques sont refusés.

## Étape 3 — Tests sur table (avant toute bascule)

Brancher un PC successivement sur chaque type de port et vérifier :

| Port de test | Attendu |
|---|---|
| hAP ether4 | IP `10.1.10.2xx`, accès WinBox `10.1.10.1` et web switch `10.1.10.2` |
| HPE port 1 (CAM) | IP `10.1.50.x`, **pas d'Internet**, pas d'accès à `10.1.10.1` |
| HPE port 6 (HOTSPOT) | IP `10.1.70.x` ou `10.1.71.x`, **page de connexion** au 1er site web ; après connexion : Internet, rien d'autre |
| HPE port 7 (RELAIS) | IP `192.168.20.1xx`, Internet, **aucun accès** à `10.1.x` ni à `192.168.1.x` |
| HPE port SFP 2 (USERS) | IP `10.1.30.x`, Internet |
| Wi-Fi « Maison » / « Maison-IoT » / « Maison-Invites » | `10.1.30.x` / `10.1.40.x` / `10.1.60.x` ; invités isolés entre eux |

Pendant les tests, le hAP ax³ sort sur Internet par son ether1, branché au switch de la maison (étape 0).

## Étape 4 — Bascule

1. Box Yas : réserver `192.168.1.2`, puis **DMZ → 192.168.1.2**.
2. Installer le hAP ax³ et le HPE 1920 à leur place définitive. Brancher la box sur ether1.
3. **MANTBox** (risque n° 1) : sauvegarder sa config, la passer en **simple point d'accès en
   pont** (portail captif désactivé ; le hotspot tourne désormais sur le hAP ax³) avec isolation
   des clients, puis la brancher (avec son injecteur) sur le **port 6**.
4. **NanoBeam** : la débrancher du Xiaomi et l'éteindre (le Xiaomi aussi : sinon deux
   serveurs DHCP `192.168.20.x`). La brancher (avec son injecteur) sur le **port 7**. Le
   hAP ax³ reprend l'adresse `192.168.20.5` et le DHCP : chez les proches, rien ne change.
   Si des CPE ont une IP fixe en `192.168.20.x`, les ajouter en baux statiques pour éviter
   les doublons.
   Ensuite, sur chaque radio (NanoBeam, LiteAP, Loco) : activer le **VLAN de management 10**
   et une IP fixe `10.1.10.3x`, une radio à la fois, en commençant par la plus éloignée.
5. Caméras : retirer le Netgear ; caméras sur les ports 1–4 et sur le switch TP-Link du port SFP 1 ; noter leurs baux
   (`10.1.50.5x+`) puis les passer en **baux statiques** `10.1.50.10–49`.
6. Proxmox Dell : **avant** de le déplacer, passer `vmbr0` en *VLAN aware* et préparer l'IP de
   gestion sur `vmbr0.20` (`10.1.20.10`) ; puis le brancher sur le **port 8** du HPE.
   Le Ryzen (ether3 du hAP ax³) fera de même avec une IP en `10.1.20.11`.
7. Switch de la maison (PC, imprimante, TV) : le relier au **port SFP 2** (VLAN 30) au lieu de
   la box. Le PC d'administration passe sur ether4 du hAP ax³ (VLAN 10).
   La box n'a alors plus qu'un câble : celui vers ether1 du hAP ax³.
8. Ajuster les plafonds `q-hotspot` et `q-relais` d'après le débit montant réel (voir les tests de débit de la box).
9. Retirer le Xiaomi et le Netgear ; sauvegarde `res-rtr-01-j1`.

## Retour arrière

Rebrancher le Xiaomi (NanoBeam) et le Netgear (HPE + caméra) sur la box, et le switch de la maison directement sur la box.
La configuration du hAP ax³ n'est pas perdue et la bascule pourra être retentée.
