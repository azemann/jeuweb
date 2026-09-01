# Côte toxique — partition de combat v001

Ce document porte l'intention créative de la mission. Il ne remplace aucune
autorité Godot : la scène maîtresse possède les placements, les Resources de
rencontre possèdent les cadences et les composants possèdent leur état runtime.

## Courbe dramatique

```text
DÉCOUVERTE → PRESSION → SURPRISE → RESPIRATION
          → TERRAIN-ARME → CHEVAUCHEMENT → PINCE
          → PRÉPARATION → DÉPLACEMENT → SILENCE → BOSS
```

La mission enseigne d'abord chaque langage séparément, les combine sur le pont,
puis demande leur maîtrise dans la fonderie.

## Cible de durée

La mission normale finale vise **4 min 30 à 6 min** lors d'un premier passage,
avec environ sept à dix moments mémorables. La scène maîtresse couvre désormais
7680 px en trois actes de 2560 px composés avec le kit publié.

La vitesse maximale auteur du joueur est de 285 px/s : traverser 7680 px sans
combat demanderait environ 27 s. La largeur n'est donc jamais le
critère d'acceptation principal. Le playtest doit mesurer :

- temps d'entrée et de sortie de chaque rencontre ;
- durée de chaque Wave et population encore active lors d'un chevauchement ;
- respiration réelle entre deux rencontres ;
- dégâts reçus, soin consommé et usage des barils ;
- durée totale hors mort et durée totale avec reprises.

Si la partition reste sous 4 min après équilibrage des beats, les rencontres
devront gagner en chorégraphie et interaction, jamais en ennemis de remplissage.

## Acte 1 — Débarquement

**Question joueur :** « Comment survivre à cette première coque ? »

| Moment | Scène / donnée | Intention |
|---|---|---|
| découverte | caisse de soin, station médicale et tour | enseigner l'interaction puis annoncer l'occupation militaire |
| pressure | 2 Troopers autour du Marker Landing | présenter tir, mouvement et première éjection de Saboteur |
| surprise | comportement Ejection du Trooper | révéler qu'une coque détruite peut libérer une menace autonome |
| release | 1 Grunt après 0,8 s | demander une visée plus précise puis laisser respirer |

Le seuil d'activation reste placé après la caisse. Aucun second Marker Landing
ne peut démarrer une cadence concurrente.

## Acte 2 — Pont acide

**Question joueur :** « Puis-je transformer le décor dangereux en avantage ? »

| Beat | Composition | Relation au niveau |
|---|---|---|
| pressure | 2 Grunts gauche → droite | cadre baril, mine et évent dans le couloir du pont |
| escalation | 2 Drones en colonne | chevauche la population terrestre et force la visée verticale au-dessus de l'acide |
| escalation | 2 Grunts en pince | ferme les deux directions autour du Marker et oblige à choisir recul, traversée ou explosion |
| résolution | checkpoint suivant accessible | le Gauntlet reste facultatif et ne ferme jamais le passage |

La vague aérienne utilise `AFTER_DELAY` : le chevauchement est intentionnel et
automatiquement protégé par le test de cadence.

## Acte 3 — Fonderie

**Question joueur :** « Puis-je reprendre l'initiative avant le Boss ? »

| Beat | Composition | Relation au niveau |
|---|---|---|
| préparation | checkpoint + armure + canon imploseur | donne une reprise propre avant la séquence finale |
| pressure | 2 Grunts | réinstalle la menace terrestre autour du baril de maîtrise |
| escalation | 1 Drone haut | déloge le joueur d'une position confortable sans saturer l'écran |
| payoff | silence de 1 s puis Boss | donne une entrée lisible au climax et conserve sa barre de vie comme feedback |
| résolution | Boss éliminé + MissionEnd | valide la victoire sans ajouter de porte physique |

## Plans de contrôle auteur

- **dramatique** : chaque Wave porte une fonction, pas seulement une quantité ;
- **spatial** : chaque Marker appartient au segment où son seuil se déclenche ;
- **tactique** : chaque prop offre une décision sans devenir obligatoire ;
- **rythmique** : seul le pont chevauche volontairement deux populations ;
- **économique** : soin, munitions, armure et Overdrive passent tous par
  `PickupData` ou `ServiceStationData` et l'inventaire de combat du joueur ;
- **spectaculaire** : explosions et Boss concluent une décision déjà comprise,
  elles ne remplacent pas la lisibilité du combat.

## Frontière d'architecture

La v001 n'ajoute ni `CombatBeatData`, ni système générique de récompense, ni
script de scénario. Si un futur besoin exige qu'une vague commande plusieurs
éléments de scène, il devra d'abord être observé dans au moins deux rencontres ;
un petit Node de correspondance visible pourra alors écouter les signaux
`encounter_started`, `wave_started` ou `encounter_completed`.

## Validation

- `map_contract_test.gd` protège les trois actes, leurs seuils, l'absence de portes et les props ;
- `encounter_cadence_contract_test.gd` protège les huit vagues, treize spawns,
  le chevauchement du pont et l'ordre dramatique complet ;
- `mission_run_contract_test.gd` protège la victoire après le seul Boss
  obligatoire et la progression monotone des checkpoints.
