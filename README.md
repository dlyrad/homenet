# Réseau multi-sites

Restructuration du réseau personnel/professionnel (Togo) : résidence, bureau, puis
sites supplémentaires. Objectifs :

1. **Un seul réseau logique** couvrant tous les sites (caméras visibles depuis les NVR
   de chaque site, serveurs joignables partout).
2. **Segmentation** propre (admin, serveurs, utilisateurs, IoT, caméras, invités).
3. **Supervision** de chaque équipement de chaque site depuis un point central.
4. **Extensible** : ajouter un site = un routeur + une config type, sans toucher aux autres.

## Sommaire

| Document | Contenu |
|---|---|
| [docs/01-contexte-inventaire.md](docs/01-contexte-inventaire.md) | Contraintes FAI, inventaire matériel existant |
| [docs/02-architecture.md](docs/02-architecture.md) | Architecture cible (hub VPS + WireGuard + OSPF) |
| [docs/03-plan-adressage.md](docs/03-plan-adressage.md) | VLAN, sous-réseaux, conventions de nommage |
| [docs/04-materiel.md](docs/04-materiel.md) | Matériel à acquérir / à réutiliser / à retirer |
| [docs/05-supervision.md](docs/05-supervision.md) | Stack de supervision et d'alerte |
| [docs/06-plan-migration.md](docs/06-plan-migration.md) | Phases de mise en œuvre |
| [docs/07-site1-cablage.md](docs/07-site1-cablage.md) | Résidence : affectation des ports hAP ax³ et HPE 1920 |
| [docs/questions-ouvertes.md](docs/questions-ouvertes.md) | Points à trancher |

## Règles du dépôt

- **Aucun secret** (clés privées WireGuard, mots de passe, tokens) dans Git.
  Les configs versionnées utilisent des placeholders `<...>`.
- Dépôt **privé** : il décrit la topologie interne.
