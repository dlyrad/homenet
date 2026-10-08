# =============================================================================
# res-rtr-01 - Routeur de la residence (site 1)
# Materiel : MikroTik hAP ax3 (C53UiG+5HPaxD2HPaxD) - RouterOS 7.23.7 (long-term)
#
# AUCUN SECRET ICI. Mots de passe Wi-Fi, compte admin, SNMP, tickets hotspot :
# voir res-rtr-01.secrets.rsc.example (a copier en res-rtr-01.secrets.rsc, jamais commite).
#
# Application (sur table, hors production) - voir docs/08-procedure-site1.md :
#   1. /system reset-configuration no-defaults=yes skip-backup=yes
#   2. Se reconnecter en WinBox par adresse MAC (PC branche sur ether4)
#   3. Glisser ce fichier dans Files, puis :  /import file-name=res-rtr-01.rsc verbose=yes
#   4. Verifier que la derniere ligne affiche "import termine sans erreur", puis
#      se reconnecter en WinBox sur 10.1.10.1 (PC sur ether4, IP auto via DHCP ADMIN)
#   5. /import file-name=res-rtr-01.secrets.rsc   puis supprimer ce fichier du routeur
#
# Ports :
#   ether1 (2,5 GbE) = WAN vers box Yas (192.168.1.2/24, passerelle 192.168.1.254, DMZ)
#   ether2           = trunk vers HPE 1920 port 5 (VLAN 10..80 tagues)
#   VLAN 80 RELAIS   = 192.168.20.0/24 (reprise du Xiaomi) : NanoBeam + MANTBox (etape A)
#   ether3           = Proxmox Ryzen (trunk 10, 20, 50 tagues)
#   ether4, ether5   = acces ADMIN (VLAN 10 non tague)
#   wifi1 (5 GHz), wifi2 (2,4 GHz) = SSID Maison (30), IoT (40, 2,4 GHz), Invites (60)
# =============================================================================

# --- Systeme -----------------------------------------------------------------
/system identity set name=res-rtr-01
/system clock set time-zone-autodetect=no time-zone-name=Africa/Lome
/system ntp client set enabled=yes
/system ntp client servers add address=pool.ntp.org
/system ntp server set enabled=yes

# --- Listes d'interfaces (zones) ----------------------------------------------
/interface list
add name=WAN comment="Sortie Internet"
add name=LAN comment="Tous les VLAN internes (DNS/DHCP/NTP vers le routeur)"
add name=Z-INTERNET comment="Zones autorisees a sortir sur Internet"
add name=Z-ADMIN
add name=Z-SERV
add name=Z-USERS
add name=Z-IOT
add name=Z-CAM
add name=Z-GUEST
add name=Z-HOTSPOT
add name=Z-RELAIS

# --- Bridge et VLAN -----------------------------------------------------------
# vlan-filtering est active tout a la fin du script.
/interface bridge
add name=br-lan protocol-mode=rstp vlan-filtering=no comment="Bridge LAN (VLAN)"

/interface vlan
add interface=br-lan name=vl10-admin vlan-id=10
add interface=br-lan name=vl20-serv vlan-id=20
add interface=br-lan name=vl30-users vlan-id=30
add interface=br-lan name=vl40-iot vlan-id=40
add interface=br-lan name=vl50-cam vlan-id=50
add interface=br-lan name=vl60-guest vlan-id=60
add interface=br-lan name=vl70-hotspot vlan-id=70
add interface=br-lan name=vl80-relais vlan-id=80

/interface bridge port
add bridge=br-lan interface=ether2 frame-types=admit-only-vlan-tagged comment="Trunk HPE 1920 port 5"
add bridge=br-lan interface=ether3 frame-types=admit-only-vlan-tagged comment="Proxmox Ryzen (trunk)"
add bridge=br-lan interface=ether4 pvid=10 frame-types=admit-only-untagged-and-priority-tagged comment="Acces ADMIN"
add bridge=br-lan interface=ether5 pvid=10 frame-types=admit-only-untagged-and-priority-tagged comment="Acces ADMIN (secours)"

/interface bridge vlan
add bridge=br-lan vlan-ids=10 tagged=br-lan,ether2,ether3 untagged=ether4,ether5 comment="ADMIN"
add bridge=br-lan vlan-ids=20 tagged=br-lan,ether2,ether3 comment="SERV"
add bridge=br-lan vlan-ids=50 tagged=br-lan,ether2,ether3 comment="CAM"
add bridge=br-lan vlan-ids=30,40,60 tagged=br-lan,ether2 comment="USERS, IOT, GUEST (Wi-Fi : entrees dynamiques)"
add bridge=br-lan vlan-ids=70,80 tagged=br-lan,ether2 comment="HOTSPOT, RELAIS"

# --- Appartenance aux zones ---------------------------------------------------
/interface list member
add list=WAN interface=ether1
add list=LAN interface=vl10-admin
add list=LAN interface=vl20-serv
add list=LAN interface=vl30-users
add list=LAN interface=vl40-iot
add list=LAN interface=vl50-cam
add list=LAN interface=vl60-guest
add list=LAN interface=vl70-hotspot
add list=LAN interface=vl80-relais
add list=Z-ADMIN interface=vl10-admin
add list=Z-SERV interface=vl20-serv
add list=Z-USERS interface=vl30-users
add list=Z-IOT interface=vl40-iot
add list=Z-CAM interface=vl50-cam
add list=Z-GUEST interface=vl60-guest
add list=Z-HOTSPOT interface=vl70-hotspot
add list=Z-RELAIS interface=vl80-relais
# CAM volontairement absent : les cameras n'ont pas acces a Internet.
add list=Z-INTERNET interface=vl20-serv
add list=Z-INTERNET interface=vl30-users
add list=Z-INTERNET interface=vl40-iot
add list=Z-INTERNET interface=vl60-guest
add list=Z-INTERNET interface=vl70-hotspot
add list=Z-INTERNET interface=vl80-relais

# --- WAN ----------------------------------------------------------------------
# Box Togocom/Yas = 192.168.1.254. Adresse fixe du hAP : 192.168.1.2, a verifier libre
# et hors de la plage DHCP de la box, puis a placer en DMZ.
/ip address add address=192.168.1.2/24 interface=ether1 comment="WAN box Yas"
/ip route add dst-address=0.0.0.0/0 gateway=192.168.1.254 comment="Defaut via box Yas"

# --- Adressage interne (site 1 = 10.1.0.0/16) ---------------------------------
/ip address
add address=10.1.10.1/24 interface=vl10-admin
add address=10.1.20.1/24 interface=vl20-serv
add address=10.1.30.1/24 interface=vl30-users
add address=10.1.40.1/24 interface=vl40-iot
add address=10.1.50.1/24 interface=vl50-cam
add address=10.1.60.1/24 interface=vl60-guest
add address=10.1.70.1/23 interface=vl70-hotspot
# RELAIS : on reprend le reseau actuel des proches (ex-routeur Xiaomi, 192.168.20.5)
# pour une bascule sans rien toucher chez eux. Exception assumee au plan 10.1.x :
# ce VLAN ne sort jamais du site. Renumerotation en 10.1.80.0/24 possible plus tard.
add address=192.168.20.5/24 interface=vl80-relais

# --- DNS ----------------------------------------------------------------------
/ip dns set allow-remote-requests=yes servers=1.1.1.1,9.9.9.9 cache-size=4096
/ip dns static add name=res-rtr-01.res.home.arpa address=10.1.10.1
/ip dns static add name=res-sw-01.res.home.arpa address=10.1.10.2

# --- DHCP ---------------------------------------------------------------------
/ip pool
add name=pool-admin ranges=10.1.10.200-10.1.10.219
add name=pool-serv ranges=10.1.20.50-10.1.20.99
add name=pool-users ranges=10.1.30.100-10.1.30.250
add name=pool-iot ranges=10.1.40.50-10.1.40.250
add name=pool-cam ranges=10.1.50.50-10.1.50.250
add name=pool-guest ranges=10.1.60.50-10.1.60.250
add name=pool-hotspot ranges=10.1.70.10-10.1.71.250
add name=pool-relais ranges=192.168.20.240-192.168.20.250 comment="Petite plage a verifier libre : les equipements des proches sont en IP fixe"

/ip dhcp-server
add name=dhcp-admin interface=vl10-admin address-pool=pool-admin lease-time=1h comment="Depannage uniquement"
add name=dhcp-serv interface=vl20-serv address-pool=pool-serv lease-time=1d
add name=dhcp-users interface=vl30-users address-pool=pool-users lease-time=1d
add name=dhcp-iot interface=vl40-iot address-pool=pool-iot lease-time=1d
add name=dhcp-cam interface=vl50-cam address-pool=pool-cam lease-time=1d comment="Passer chaque camera en bail statique (.10-.49)"
add name=dhcp-guest interface=vl60-guest address-pool=pool-guest lease-time=2h
add name=dhcp-hotspot interface=vl70-hotspot address-pool=pool-hotspot lease-time=1h
add name=dhcp-relais interface=vl80-relais address-pool=pool-relais lease-time=1d disabled=yes comment="Desactive : proches en IP fixe (ex-Xiaomi). Activer apres inventaire"

/ip dhcp-server network
add address=10.1.10.0/24 gateway=10.1.10.1 dns-server=10.1.10.1 ntp-server=10.1.10.1 domain=res.home.arpa
add address=10.1.20.0/24 gateway=10.1.20.1 dns-server=10.1.20.1 ntp-server=10.1.20.1 domain=res.home.arpa
add address=10.1.30.0/24 gateway=10.1.30.1 dns-server=10.1.30.1 domain=res.home.arpa
add address=10.1.40.0/24 gateway=10.1.40.1 dns-server=10.1.40.1 ntp-server=10.1.40.1
add address=10.1.50.0/24 gateway=10.1.50.1 dns-server=10.1.50.1 ntp-server=10.1.50.1
add address=10.1.60.0/24 gateway=10.1.60.1 dns-server=10.1.60.1
add address=10.1.70.0/23 gateway=10.1.70.1 dns-server=10.1.70.1
add address=192.168.20.0/24 gateway=192.168.20.5 dns-server=192.168.20.5

# --- Activation du filtrage VLAN ---------------------------------------------
# Fait tot : si une ligne suivante echoue, ether4 donne deja une IP (VLAN 10, DHCP)
# et le routeur reste joignable sur 10.1.10.1.
# La session WinBox-MAC peut etre coupee ici : se reconnecter sur 10.1.10.1 via ether4.
/interface bridge set br-lan frame-types=admit-only-vlan-tagged vlan-filtering=yes

# --- Partage du debit (hotspot et proches) ------------------------------------
# max-limit = montant/descendant (vu des clients). Valeurs de depart ~ 40 % d'un
# lien 30/200 Mb/s : a ajuster apres mesure du montant reel de la box Yas.
/queue type
add name=pcq-up kind=pcq pcq-classifier=src-address
add name=pcq-down kind=pcq pcq-classifier=dst-address

/queue simple
add name=q-hotspot target=10.1.70.0/23 max-limit=6M/40M comment="HOTSPOT : plafond global (parent des files par client)"
add name=q-relais target=192.168.20.0/24 max-limit=6M/40M queue=pcq-up/pcq-down comment="RELAIS : plafond global, partage equitable par CPE"
# Pas de fasttrack : il contournerait ces files d'attente. Le CPU du hAP ax3 suffit a 200 Mb/s.

# --- Hotspot (portail captif sur le routeur ; la MANTBox devient un simple AP) -
/ip hotspot profile
add name=hsprof-res hotspot-address=10.1.70.1 dns-name=login.wifi html-directory=hotspot login-by=http-chap,cookie use-radius=no

/ip hotspot user profile
add name=up-standard rate-limit=2M/6M shared-users=1 parent-queue=q-hotspot

/ip hotspot
add name=hs-res interface=vl70-hotspot address-pool=none profile=hsprof-res disabled=no
# Si les pages de connexion sont absentes : /ip hotspot reset-html hs-res

# --- Pare-feu : entree (vers le routeur) --------------------------------------
/ip firewall filter
add chain=input action=accept connection-state=established,related,untracked comment="IN: connexions etablies"
add chain=input action=drop connection-state=invalid comment="IN: invalides"
add chain=input action=accept protocol=icmp comment="IN: ICMP"
add chain=input action=accept in-interface-list=Z-ADMIN comment="IN: ADMIN -> routeur (WinBox, SSH)"
add chain=input action=accept in-interface-list=LAN protocol=udp dst-port=53,67,123 comment="IN: DNS, DHCP, NTP depuis les VLAN"
add chain=input action=accept in-interface-list=LAN protocol=tcp dst-port=53 comment="IN: DNS TCP"
add chain=input action=accept in-interface-list=Z-HOTSPOT protocol=tcp dst-port=80,64872-64875 comment="IN: portail captif"
add chain=input action=accept in-interface-list=Z-SERV protocol=tcp dst-port=8728 disabled=yes comment="IN: API RouterOS pour Mikhmon (etape B)"
add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=13231 disabled=yes comment="IN: WireGuard inter-sites (phase 3)"
add chain=input action=drop comment="IN: tout le reste"

# --- Pare-feu : transit entre zones -------------------------------------------
add chain=forward action=accept connection-state=established,related,untracked comment="FWD: connexions etablies"
add chain=forward action=drop connection-state=invalid comment="FWD: invalides"
add chain=forward action=accept in-interface-list=Z-ADMIN comment="FWD: ADMIN -> tout"
add chain=forward action=accept in-interface-list=Z-SERV out-interface-list=Z-IOT comment="FWD: SERV -> IOT (Home Assistant, supervision)"
add chain=forward action=accept in-interface-list=Z-SERV out-interface-list=Z-CAM comment="FWD: SERV -> CAM (Frigate, NVR)"
add chain=forward action=accept in-interface-list=Z-USERS out-interface-list=Z-SERV comment="FWD: USERS -> SERV"
add chain=forward action=accept in-interface-list=Z-USERS out-interface-list=Z-IOT comment="FWD: USERS -> IOT (cast, commandes locales)"
add chain=forward action=accept in-interface-list=Z-INTERNET out-interface-list=WAN comment="FWD: zones autorisees -> Internet"
add chain=forward action=drop comment="FWD: tout le reste (dont CAM -> Internet, HOTSPOT/RELAIS -> interne)"

/ip firewall nat
add chain=srcnat action=masquerade out-interface-list=WAN comment="NAT sortie Internet"

# --- Wi-Fi (wifi-qcom) --------------------------------------------------------
# Les interfaces restent desactivees : le fichier secrets pose les mots de passe
# puis les active. wifi1 = 5 GHz, wifi2 = 2,4 GHz (a verifier dans /interface wifi).
/interface wifi security
add name=sec-maison authentication-types=wpa2-psk,wpa3-psk
add name=sec-iot authentication-types=wpa2-psk
add name=sec-invites authentication-types=wpa2-psk,wpa3-psk

/interface wifi datapath
add name=dp-users bridge=br-lan vlan-id=30
add name=dp-iot bridge=br-lan vlan-id=40
add name=dp-invites bridge=br-lan vlan-id=60 client-isolation=yes

/interface wifi configuration
add name=cfg-maison mode=ap ssid="Maison" country=Togo security=sec-maison datapath=dp-users
add name=cfg-iot mode=ap ssid="Maison-IoT" country=Togo security=sec-iot datapath=dp-iot
add name=cfg-invites mode=ap ssid="Maison-Invites" country=Togo security=sec-invites datapath=dp-invites

/interface wifi
# Redonne leurs noms d'origine aux radios (elles peuvent avoir ete renommees, ex. "Mikrotik")
set [find default-name=wifi1] name=wifi1
set [find default-name=wifi2] name=wifi2
set [find default-name=wifi1] configuration=cfg-maison channel.band=5ghz-ax channel.width=20/40/80mhz disabled=yes
set [find default-name=wifi2] configuration=cfg-maison channel.band=2ghz-ax channel.width=20mhz disabled=yes
add name=wifi2-iot master-interface=wifi2 configuration=cfg-iot disabled=yes
add name=wifi1-invites master-interface=wifi1 configuration=cfg-invites disabled=yes
add name=wifi2-invites master-interface=wifi2 configuration=cfg-invites disabled=yes

# --- DDNS (pour les tunnels WireGuard de la phase 3) --------------------------
:do { /ip cloud set ddns-enabled=yes ddns-update-interval=5m } on-error={ :log warning "res-rtr-01: DDNS IP Cloud non active" }

# --- Durcissement -------------------------------------------------------------
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set www-ssl disabled=yes
/ip service set api disabled=yes address=10.1.10.0/24,10.1.20.0/24
/ip service set api-ssl disabled=yes
/ip service set ssh address=10.1.10.0/24
/ip service set winbox address=10.1.10.0/24
/ip ssh set strong-crypto=yes
/tool bandwidth-server set enabled=no
:do { /snmp community set [find name=public] disabled=yes } on-error={ :log warning "res-rtr-01: communaute SNMP public non desactivee" }
# Groupe limite pour Mikhmon (gestion des tickets via API, etape B)
/user group add name=mikhmon policy=read,write,policy,test,api,sensitive

# --- Restriction de l'acces MAC (tout a la fin, une fois tout le reste applique) -
/tool mac-server set allowed-interface-list=Z-ADMIN
/tool mac-server mac-winbox set allowed-interface-list=Z-ADMIN
/ip neighbor discovery-settings set discover-interface-list=Z-ADMIN

:log info "res-rtr-01.rsc : import termine sans erreur"
:put "=== res-rtr-01.rsc : import termine sans erreur ==="
