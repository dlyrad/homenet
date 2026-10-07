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

## Étape 1 — hAP ax³ : appliquer la configuration

### 1.1 Préparer les fichiers sur le PC

1. Télécharger **WinBox 4** (mikrotik.com → Software → WinBox).
2. Récupérer le dépôt : `git clone https://github.com/dlyrad/homenet` (ou *Code → Download ZIP*).
3. Relire `configs/res-rtr-01.rsc` : noms de Wi-Fi, adresse WAN `192.168.1.2`, passerelle
   `192.168.1.254`. Modifier si besoin (Bloc-notes ou VS Code).
4. Copier `configs/res-rtr-01.secrets.rsc.example` en **`res-rtr-01.secrets.rsc`** (hors du
   dossier Git, par ex. dans `Documents\homenet-secrets\`), remplacer chaque `<...>` par une
   vraie valeur. Mots de passe Wi-Fi : 12 caractères minimum.

> Les deux fichiers sont en ASCII (sans accents) : RouterOS les importe sans souci d'encodage.

### 1.2 Mettre à jour le routeur (configuration d'usine encore active)

1. Câblage de l'étape 0 : **ether1** → switch de la maison, **PC → ether4**.
   Le PC reçoit une adresse `192.168.88.x` du hAP ax³ (configuration d'usine).
2. WinBox → onglet **Neighbors** → cliquer sur l'adresse **MAC** du hAP ax³ → compte `admin`,
   mot de passe imprimé sur l'**étiquette** du routeur.
3. **System → Packages → Check For Updates** : *Channel* = **long-term** → *Download&Install*.
   Le routeur redémarre. Vérifier que `wifi-qcom` figure dans la liste des paquets.
4. **System → RouterBOARD → Upgrade**, puis **System → Reboot** (mise à jour du firmware).

### 1.3 Remise à zéro sans configuration

1. **System → Reset Configuration** : cocher **No Default Configuration** et **Do Not Backup**
   → *Reset Configuration*. (En terminal : `/system reset-configuration no-defaults=yes skip-backup=yes`.)
2. Le routeur redémarre **vide** (aucune IP). Le PC n'a plus d'adresse : c'est normal.
3. WinBox → **Neighbors** → connexion par **MAC** (`admin` + mot de passe de l'étiquette).

### 1.4 Importer la configuration

1. **Files** → glisser-déposer `res-rtr-01.rsc` dans la fenêtre.
2. **New Terminal** :
   ```
   /import file-name=res-rtr-01.rsc verbose=yes
   ```
3. Le terminal affiche chaque commande. À la dernière ligne (filtrage VLAN), la session WinBox
   peut se couper : **c'est normal**.
4. Le PC (sur ether4, en DHCP) reçoit une adresse `10.1.10.2xx`. Si ce n'est pas le cas : débrancher
   puis rebrancher le câble, ou `ipconfig /renew` dans PowerShell.
5. WinBox → se connecter à **`10.1.10.1`** (`admin` + mot de passe de l'étiquette).

> **En cas d'erreur pendant l'import** : l'import s'arrête à la ligne fautive. Noter le message,
> me l'envoyer, puis **recommencer depuis 1.3** (remise à zéro) avec le script corrigé : un
> import partiel ne doit pas être complété à la main.

### 1.5 Secrets, puis compte administrateur

1. **Files** → déposer `res-rtr-01.secrets.rsc`, puis :
   ```
   /import file-name=res-rtr-01.secrets.rsc verbose=yes
   /file remove res-rtr-01.secrets.rsc
   ```
2. **Se déconnecter**, se reconnecter à `10.1.10.1` avec le **nouveau compte** ; si ça marche :
   ```
   /user remove admin
   ```

### 1.6 Vérifications

```
/ip address print
/interface bridge vlan print
/ping 1.1.1.1 count=3
/ip dns cache print count-only
/ip dhcp-server lease print
/interface wifi print
```
Attendu : les 8 adresses `10.1.x.1` + `192.168.20.5` + `192.168.1.2` ; le ping répond ; le PC
navigue sur Internet ; les Wi-Fi « Maison », « Maison-IoT » et « Maison-Invites » sont visibles.

### 1.7 Sauvegarde

```
/system backup save name=res-rtr-01-j0
/export file=res-rtr-01-j0
```
**Files** → récupérer les deux fichiers sur le PC (dans `homenet-secrets`, **jamais dans Git**).

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
   | 1, 3, 4 | Access | 50 | 50 | — |
   | 2 | Access | 30 | 30 | — |
   | 6 | Access | **70 pendant les tests**, puis **80** à la bascule | idem | — |
   | 7 | **Hybrid** | 80 | 80 | 10 |
   | 8 | Trunk | 1 | — | 10, 20 |
   | SFP 1–2 | — | — | — | — (désactivés) |
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
| HPE port 6 (HOTSPOT, provisoirement en VLAN 70) | IP `10.1.70.x` ou `10.1.71.x`, **page de connexion** au 1er site web ; après connexion : Internet, rien d'autre |
| HPE port 7 (RELAIS) | IP `192.168.20.1xx`, Internet, **aucun accès** à `10.1.x` ni à `192.168.1.x` |
| HPE port 2 (USERS) | IP `10.1.30.x`, Internet |

Après les tests : passer le **port 6 en VLAN 80** (PVID 80, non tagué 80) et **enregistrer** (*Save*).
| Wi-Fi « Maison » / « Maison-IoT » / « Maison-Invites » | `10.1.30.x` / `10.1.40.x` / `10.1.60.x` ; invités isolés entre eux |

Pendant les tests, le hAP ax³ sort sur Internet par son ether1, branché au switch de la maison (étape 0).

## Étape 4 — Bascule

1. Box Yas : réserver `192.168.1.2`, puis **DMZ → 192.168.1.2**.
2. Installer le hAP ax³ et le HPE 1920 à leur place définitive. Brancher la box sur ether1.
3. **Avant d'éteindre le Xiaomi** : relever dans son interface la liste des appareils connectés
   (IP + MAC) et vérifier que les équipements à IP fixe des proches ont bien `192.168.20.5`
   comme passerelle. Cette liste devient l'inventaire du VLAN 80 (NetBox).
4. **Xiaomi → hAP ax³** : éteindre le Xiaomi, puis brancher la **NanoBeam** sur le **port 7** et
   la **MANTBox** sur le **port 6** (VLAN 80, chacune avec son injecteur). Le hAP ax³ reprend
   l'adresse `192.168.20.5` : pour les proches et pour la MANTBox, rien ne change, mais **ils
   n'atteignent plus la maison**. C'est la fin du risque n° 1.
   Le DHCP du VLAN 80 reste **désactivé** (tous les équipements sont en IP fixe) ; à activer
   plus tard sur une petite plage vérifiée libre (`/ip dhcp-server enable dhcp-relais`).
   Ensuite, sur chaque radio (NanoBeam, LiteAP, Loco) : activer le **VLAN de management 10**
   et une IP fixe `10.1.10.3x`, une radio à la fois, en commençant par la plus éloignée.
5. **MANTBox, étape B (plus tard)** : le hotspot et ses tickets passent sur le hAP ax³ ;
   la MANTBox est réinitialisée en simple point d'accès. Voir la section « Étape B » ci-dessous.
6. Caméras (PoE + Wi-Fi) : on les **câble en PoE** (plus fiable, pas de Wi-Fi à sécuriser) sur
   les **ports 1, 3 et 4**. Retirer le Netgear. Noter leurs baux (`10.1.50.5x+`) puis les passer en
   **baux statiques** `10.1.50.11–13`. Effacer ou désactiver leur configuration Wi-Fi (elles
   n'ont de toute façon plus accès au cloud Tuya).
7. Proxmox Dell : **avant** de le déplacer, passer `vmbr0` en *VLAN aware* et préparer l'IP de
   gestion sur `vmbr0.20` (`10.1.20.10`) ; puis le brancher sur le **port 8** du HPE.
   Le Ryzen (ether3 du hAP ax³) fera de même avec une IP en `10.1.20.11`.
8. Switch de la maison (PC, imprimante, TV) : le relier au **port 2** (VLAN 30) au lieu de
   la box. Le PC d'administration passe sur ether4 du hAP ax³ (VLAN 10).
   La box n'a alors plus qu'un câble : celui vers ether1 du hAP ax³.
9. Ajuster les plafonds `q-hotspot` et `q-relais` d'après le débit montant réel (voir les tests de débit de la box).
10. Retirer le Xiaomi et le Netgear ; sauvegarde `res-rtr-01-j1`.

## Étape B — Hotspot sur le hAP ax³ + Mikhmon (plus tard)

Mikhmon gère les tickets via l'**API RouterOS** (port TCP 8728) : il suffit de le faire pointer
vers le hAP ax³ au lieu de la MANTBox. Détails, droits et précautions : [09-mikhmon.md](09-mikhmon.md).

1. **Exporter depuis la MANTBox** (avant toute réinitialisation) :
   ```
   /ip hotspot user profile export file=hs-profils
   /ip hotspot user export file=hs-comptes
   /system script export file=hs-scripts
   /system scheduler export file=hs-planif
   ```
   Récupérer aussi le dossier `hotspot/` (pages de connexion personnalisées), puis faire une
   sauvegarde complète : `/system backup save name=mantbox-avant-reset`.
   Ces fichiers contiennent des mots de passe : **jamais dans Git**.
2. **Nettoyer** `hs-profils.rsc` : retirer `address-pool=` et `parent-queue=` propres à la
   MANTBox, ajouter `parent-queue=q-hotspot` à chaque profil. Garder les `on-login` (scripts
   Mikhmon qui gèrent l'expiration des tickets).
3. **Importer sur le hAP ax³**, dans l'ordre : profils, scripts, planificateur, comptes ;
   copier les pages personnalisées dans `hotspot/`.
4. **Ouvrir l'API au seul Mikhmon** :
   ```
   /ip service set api disabled=no address=10.1.10.0/24,10.1.20.0/24
   /ip firewall filter enable [find comment="IN: API RouterOS pour Mikhmon (etape B)"]
   ```
   Le compte `mikhmon` (groupe `mikhmon`) est créé par le fichier secrets.
   Dans Mikhmon, nouvelle session : adresse **`10.1.10.1`** (Mikhmon sur le PC admin) ou
   **`10.1.20.1`** (Mikhmon sur un serveur du VLAN 20), utilisateur `mikhmon`, port 8728,
   hotspot `hs-res`.
5. **Réinitialiser la MANTBox** en point d'accès simple : *Quick Set → Mode : Bridge* (ou
   `no-defaults` puis un bridge `wlan1 + ether1`), SSID du hotspot, **sans sécurité** (le portail
   fait l'authentification), **Default Forward décoché** (isolation des clients), IP de
   gestion fixe `10.1.10.31` plus tard via VLAN 10.
6. **Basculer** : port 6 du HPE en **VLAN 70**, *Save*. Tester un ticket existant et un ticket
   neuf généré par Mikhmon.
7. **Retour arrière** : port 6 en VLAN 80, restaurer `mantbox-avant-reset.backup` sur la MANTBox.

> Mikhmon parle à l'API **en clair** : il ne doit jamais être exposé à Internet. La « version
> améliorée » envisagée pourra utiliser l'**API REST** de RouterOS v7 (HTTPS) à la place.

## Retour arrière

Rebrancher le Xiaomi (NanoBeam) et le Netgear (HPE + caméra) sur la box, et le switch de la maison directement sur la box.
La configuration du hAP ax³ n'est pas perdue et la bascule pourra être retentée.
