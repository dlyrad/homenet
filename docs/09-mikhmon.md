# 09 — Mikhmon (gestion des tickets du hotspot)

## État actuel (analyse de l'archive `mikhmonv3ws.zip`, 2026-10-07)

| Élément | Constat | Conséquence |
|---|---|---|
| Version | **Mikhmon 3.20** (06-2021), paquet « Mikhmon Server » pour Windows | Fonctionne, mais n'est plus maintenu |
| Moteur PHP embarqué | **PHP 5.4.17** (2013, sans correctifs depuis 2015) | Nombreuses failles connues : ne jamais l'exposer au-delà du VLAN ADMIN |
| Serveur web | `MikhmonServer.exe`, **port 80** (`php/port.ini`) | Toute machine qui joint le PC sur le port 80 voit la page de connexion |
| Configuration | `mikhmon/include/config.php` **d'usine** : aucun routeur enregistré, identifiant d'administration par défaut | **Changer l'identifiant et le mot de passe Mikhmon dès le premier lancement** |
| Connexion au routeur | API RouterOS **en clair**, port **8728** (l'option SSL de la bibliothèque n'est pas utilisée) | API limitée par adresse source + pare-feu |
| Ce que Mikhmon écrit sur le routeur | comptes et profils hotspot, scripts `on-login`, **scripts** et **planificateurs** (expiration des tickets, rapports de vente) ; options reboot/shutdown | Droits du compte API : voir ci-dessous |

L'archive (21 Mo, binaires Windows + code tiers GPL) **n'est pas versionnée** dans ce dépôt.

**Décision (2026-10-08)** : Mikhmon est conservé tel quel pour le moment. Ses paramètres
(profils, tickets, scripts) ont été **saisis sur le hAP ax³** avant l'application du script
`res-rtr-01.rsc`. La remise à zéro de l'étape 1.3 les effacera : **les exporter avant**
(voir [08-procedure-site1.md](08-procedure-site1.md), étape 1.2 bis).

## Raccordement au hAP ax³ (étape B)

- Compte dédié `mikhmon`, groupe `mikhmon` : `read, write, policy, test, api, sensitive`
  (créer scripts et planificateurs exige `policy`). **Pas** de `reboot`, `ftp` ni `password` :
  les boutons Redémarrer/Éteindre de Mikhmon resteront sans effet, volontairement.
- Service API : `address=10.1.10.0/24,10.1.20.0/24`, ouvert seulement à l'étape B.
- Pare-feu : depuis ADMIN, déjà autorisé ; depuis SERV, règle « IN: API RouterOS pour Mikhmon ».
- Dans Mikhmon → *Add Router* : IP `10.1.10.1`, utilisateur `mikhmon`, nom du hotspot `hs-res`,
  DNS name `login.wifi`, devise `XOF`.

## Où le faire tourner

| Option | Où | Pour | Contre |
|---|---|---|---|
| **A — maintenant** | PC Windows d'administration (VLAN 10, ether4 du hAP ax³) | Rien à changer, déjà en place | Dépend du PC allumé ; PHP 5.4 ; port 80 ouvert sur le PC |
| B — ensuite | Conteneur sur le Proxmox Dell (VLAN 20), PHP 7.4 + Apache | Toujours disponible, isolé, sauvegardé | À préparer ; Mikhmon 3 n'est pas garanti sous PHP 8 |

Pour l'option A : dans le **pare-feu Windows**, limiter le port 80 de `MikhmonServer.exe` au
réseau `10.1.10.0/24` (profil *Privé*) et ne jamais le rendre accessible depuis le Wi-Fi invités ou le hotspot.

## Version améliorée (plus tard)

Pistes pour remplacer Mikhmon :
- **API REST** de RouterOS v7 (HTTPS, `www-ssl`) au lieu de l'API en clair ;
- comptes séparés par vendeur de tickets, journal des ventes en base de données ;
- prix en **XOF** sans décimales, impression de tickets, paiement mobile (T-Money, Flooz) ;
- exécution sur le Proxmox, accès par le VPN uniquement.
