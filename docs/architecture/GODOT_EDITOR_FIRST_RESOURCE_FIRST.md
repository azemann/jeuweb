# Godot — socle editor-first / resource-first

Ce document est une instruction d'architecture obligatoire pour l'ensemble du
jeu.

Godot doit être exploité dans cet ordre conceptuel :

```text
Éditeur → Scènes → Nodes → Resources → Inspector → Signaux
        → Animations → Scripts
```

Le projet doit rester compréhensible, modifiable et extensible directement
depuis l'éditeur Godot.

## 1. Principe fondamental

Pour chaque fonctionnalité, demander d'abord quelle partie appartient
naturellement à l'éditeur, à une scène, à un Node, à une Resource, à
l'Inspector, à un signal ou à un système natif. Ne pas commencer
automatiquement par un gros script ; rechercher la représentation Godot
naturelle du problème.

## 2. Ordre de priorité

Privilégier, dans cet ordre : fonctionnalités natives de Godot, scène `.tscn`,
Nodes appropriés, Resources `.tres`/`.res`, propriétés Inspector, composition
de scènes, signaux, AnimationPlayer/AnimationTree, groupes et métadonnées,
scripts composants spécialisés, Autoloads réellement globaux, puis code
personnalisé complexe seulement si aucune abstraction Godot naturelle ne
convient.

## 3. Editor-first

Tout ce qu'un designer ou artiste peut raisonnablement modifier doit être
accessible dans l'éditeur : dégâts, vie, vitesse, cooldown, portée, masse,
armes, ennemis, vagues, animations, sons, textures, VFX, scènes, recettes,
loot, projectiles, interactions et règles de spawn.

Éviter constantes dispersées et valeurs métier enfouies. Utiliser lorsque
pertinent `@export`, `@export_range`, `@export_enum`, `@export_group` et
`@export_subgroup`.

## 4. Resource-first

Une définition, configuration, recette, statistique ou contenu devient
candidate à une Resource : WeaponData, EnemyData, CharacterData,
ProjectileData, ItemData, LootTable, WaveData, StatusEffectData, DialogueData
ou LevelData.

```text
COMPORTEMENT                  DONNÉES
Script / Component          Resource
       └──────────┬───────────┘
                  ▼
                Scène
```

Le script sait comment quelque chose fonctionne ; la Resource décrit ce que
cette chose est.

## 5. Scene-first

Tout objet existant dans le jeu est candidat à une scène réutilisable : joueur,
ennemi, projectile, arme, pickup, porte, coffre, explosion, effet, arène ou
widget. Préférer la composition de petites scènes à une énorme scène pilotée
par un énorme script.

## 6. Composition avant héritage

Privilégier des composants à responsabilité unique : Movement, Combat, Health,
Equipment, Interaction, Hurtbox. Ne pas concentrer toutes les fonctions du
joueur dans `player.gd`.

## 7. Correspondances Godot

| Concept | Représentation naturelle |
|---|---|
| objet physique | Node2D / Node3D |
| personnage | CharacterBody2D / CharacterBody3D |
| projectile | Area2D/3D ou CharacterBody selon son comportement |
| collision ou détection | CollisionShape2D/3D, Area2D/3D |
| donnée configurable | Resource |
| objet réutilisable | PackedScene |
| animation déterministe | AnimationPlayer |
| animation complexe | AnimationTree |
| événement local | Signal |
| catégorie d'objets | Group |
| propriété designer | `@export` |
| minuterie | Timer |
| navigation | NavigationAgent |
| son positionnel | AudioStreamPlayer2D/3D |
| état visuel | animation, shader ou material |
| interface / collection UI | Control / Container |
| données persistantes | Resource ou sérialisation dédiée |
| niveau 2D / tuiles | TileMapLayer / TileSet |
| comportement réutilisable | composant Node + script |
| système véritablement global | Autoload |

## 8. Avant de créer du code

Vérifier : Node natif existant, Resource adaptée, scène possible, propriété à
exposer, AnimationPlayer à la place d'un timing codé, signal pour découpler,
groupe à la place d'une liste, composant isolable, réelle nécessité d'un
singleton et nature éditable ou codée de la donnée. Ne pas réimplémenter un
mécanisme fourni par Godot.

## 9. Signaux et découplage

Éviter les chaînes de parents et références arbitraires. Un événement descend
par signal vers les systèmes intéressés. Les signaux représentent les
événements ; les appels directs représentent les commandes intentionnelles.
Ne pas remplacer systématiquement l'un par l'autre.

## 10. Animations

Ne pas coder une séquence temporelle qu'AnimationPlayer peut décrire. Une
attaque peut y orchestrer anticipation, hitbox, impact, sons, particules et
récupération. Le script déclenche l'action ; AnimationPlayer en porte le timing
précis lorsque pertinent.

## 11. Data-driven

Lorsque plusieurs objets partagent un comportement, ne pas brancher le code
sur leurs identités. Faire consommer au système une Resource contenant dégâts,
portée, cooldown, scène, animation, effets et paramètres spécifiques.

## 12. Inspector comme interface de game design

Les propriétés exposées sont clairement nommées, regroupées, typées,
documentées, bornées et dotées de valeurs par défaut raisonnables. Structurer
l'Inspector par domaines tels que Movement, Combat et Feedback.

## 13. Outils d'éditeur

Considérer `@tool`, EditorPlugin, EditorInspectorPlugin, custom Resource,
custom Node, gizmo, dock ou import plugin pour un workflow répétitif. Ne pas
créer d'outil sans nécessité, mais signaler lorsqu'il améliorerait fortement
le travail auteur.

## 14. Autoloads

Un Autoload correspond uniquement à un système réellement global : sauvegarde,
routage de scènes, audio, session ou réglages. Une arme, un inventaire local,
un ennemi, une attaque ou une UI locale ne deviennent pas singletons pour
faciliter l'accès.

## 15. Arborescence

Organiser par domaine : characters, components, enemies, items, weapons,
abilities, levels, environments, UI, effects, audio, data, systems et tools.
Les scènes, scripts et Resources liés restent faciles à retrouver ensemble.

## 16. Frontière code / données / assets

```text
ASSET → DATA/Resource → SCENE/assemblage → BEHAVIOR/composants
      → SYSTEM/orchestration
```

Ne pas mélanger ces niveaux. Les sources d'assets sont en plus isolées du
runtime selon `docs/assets/ASSET_PIPELINE_CONTRACT.md`.

## 17. Analyse d'une nouvelle fonctionnalité

Avant implémentation : concept, autorité, correspondance Godot, données,
Resource éventuelle, scène, Nodes, composants, signaux, animations, Inspector,
script minimal nécessaire, validation.

## 18. Modification d'un projet existant

Inspecter scènes, Resources, scripts, Nodes et conventions déjà présents.
Rechercher les systèmes natifs et workflows éditeur existants. Ne pas créer
d'architecture parallèle ni remplacer une architecture Godot correcte par une
architecture purement code plus familière.

## 19. Critère de qualité

Une fonctionnalité est intégrée lorsqu'on peut ouvrir Godot et comprendre sa
scène, ses données, ses Nodes, ses réglages, ses Resources, ses événements et
ses composants sans devoir lire tout le code.

## 20. Règle de sortie

Pour une architecture importante, indiquer seulement les catégories utiles :
scènes, Nodes, Resources, Inspector, signaux, animations, composants, scripts,
Autoloads et outils éditeur. Ne pas inventer une catégorie inutile.

## 21. Règle absolue

Ne jamais transformer Godot en simple runtime pour une architecture construite
entièrement en scripts. Le projet reste editor-first, scene-first,
resource-first, data-driven et composé. Le code complète Godot ; il ne le
remplace pas.

## 22. Autorité unique pour chaque information

Avant de coder, désigner l'autorité de chaque donnée. Une Resource peut être
l'autorité d'une définition, une scène maîtresse celle du placement final, un
composant celle de l'état runtime et un outil externe celle d'une source
massive. La même information ne doit jamais être maintenue parallèlement dans
plusieurs de ces endroits.

Toute proposition de système doit pouvoir répondre à la question : « Qui est
l'autorité ? »

## 23. Architecture visible dans Godot

Une responsabilité majeure doit idéalement avoir une représentation visible
dans le SceneTree ou l'Inspector. Ouvrir la scène maîtresse doit permettre de
voir ses systèmes, composants, caméra, interface, persistance et points
d'orchestration importants sans découvrir leur existence uniquement dans le
code.

La visibilité architecturale ne signifie pas créer un Node vide pour chaque
idée : le Node ou la Resource doit posséder une responsabilité réelle.

## 24. Resources-panneaux

Lorsqu'une famille cohérente de paramètres forme un véritable domaine de
réglage, demander si elle mérite son propre panneau `.tres`. Les Resources de
configuration doivent devenir des interfaces de production lisibles et
réutilisables, plutôt qu'un grand nombre d'exports dispersés dans les scènes.

## 25. Définition, instance runtime et représentation

Séparer systématiquement lorsque pertinent :

```text
DEFINITION — Resource stable et partageable
    ↓
INSTANCE RUNTIME — état particulier, mutable ou sauvegardable
    ↓
PRESENTATION — scène, sprite, animation, audio et VFX
```

Cette séparation s'applique notamment aux objets, ennemis, armes, quêtes,
buffs, PNJ et compétences. La représentation ne devient pas l'autorité de
l'état, et l'état runtime ne modifie pas sa définition partagée.

## 26. Scène canonique par famille

Si une famille d'objets partage une structure comportementale, créer une scène
canonique composée de composants spécialisés plutôt qu'une multitude
d'assemblages divergents. Les variantes consomment des Resources ou spécialisent
des enfants prévus à cet effet.

## 27. Le pipeline fabrique, Godot consomme

Le flux est unidirectionnel :

```text
source artistique
      ↓
pipeline / génération
      ↓
asset runtime publié
      ↓
Resource gameplay
      ↓
scène Godot
```

Godot ne devient jamais l'autorité des sources de fabrication. Le pipeline ne
dépend jamais des scènes runtime. Le contrat détaillé se trouve dans
`docs/assets/ASSET_PIPELINE_CONTRACT.md`.

## 28. Generated n'est pas authored

Toujours distinguer :

```text
SOURCE
   ↓
GENERATED — ne pas éditer manuellement
   ↓
MASTER SCENE — surcharges finales éditables
   ↓
RUNTIME
```

Chaque dossier ou fichier généré doit être identifiable comme tel. Une
régénération ne doit jamais écraser silencieusement les choix gameplay de la
scène maîtresse.

## 29. Correspondances explicites entre outils

Lorsqu'un outil externe produit des concepts que Godot doit instancier, créer
une correspondance explicite et inspectable : type externe, propriétés,
registre ou adaptateur, PackedScene, instance configurée. Ne pas disperser ces
traductions dans des conditions et noms magiques.

## 30. Triple contrat des systèmes importants

Chaque système important doit distinguer :

- le contrat runtime : responsabilités et interactions pendant le jeu ;
- le contrat auteur : comment fabriquer et configurer correctement le contenu ;
- le contrat de validation : invariants vérifiés automatiquement.

Les contrats auteur sont aussi importants que les scripts : ils protègent le
workflow de production.

## 31. Validation architecturale

Les tests ne vérifient pas seulement les résultats fonctionnels. Ils doivent
aussi protéger les autorités, branches de scènes obligatoires, identifiants,
registries, Resources attendues, frontière generated/authored et absence de
dépendances interdites.

## 32. La transformation auteur est souveraine

Pour toute pièce ou objet placé dans une scène maîtresse, le Transform du Node
est l'autorité de position, rotation, échelle et miroir. Les systèmes dérivés
adaptent présentation, collision, masque et sockets à ce Transform complet.
Ils ne restreignent pas l'éditeur pour masquer une incapacité technique.

Le contrat transversal détaillé se trouve dans
`docs/architecture/AUTHORED_TRANSFORM_CONTRACT.md`.

## 33. Les pieds et les ombres dépendent du vrai sol

Toute scène canonique de joueur ou d'ennemi expose un `GroundAnchor`, un probe
World et une ombre projetée extérieure à sa Presentation. Permanent et
Breakable utilisent un contour auteur inspectable ; Carvable utilise uniquement
son masque et ses collisions runtime. Une ellipse attachée au sprite ou une
collision alpha approximative ne constitue jamais une solution finale.

Le contrat transversal détaillé se trouve dans
`docs/architecture/ACTOR_GROUNDING_AND_WALK_SURFACE_CONTRACT.md`.

## Questions obligatoires avant implémentation

1. Qui est l'autorité de chaque donnée ?
2. Où l'auteur modifie-t-il cela dans Godot ?
3. Quelle correspondance relie cette donnée aux autres systèmes ou outils ?
4. Comment vérifier automatiquement que cette architecture reste vraie ?

## Formule mature

```text
                    CONCEPT
                       │
                       ▼
                   AUTORITÉ
                       │
           ┌───────────┼───────────┐
           ▼           ▼           ▼
        SOURCE       DATA       RUNTIME
           │           │           │
           ▼           ▼           ▼
       Pipeline      Resource      Node
           │           │           │
           └──────┬────┴─────┬─────┘
                  ▼          ▼
            CORRESPONDANCE   SCÈNE
                  │          │
                  └────┬─────┘
                       ▼
                    INSPECTOR
                       │
                       ▼
              COMPOSANTS / SIGNAUX
                       │
                       ▼
                 CODE MINIMAL
                       │
                       ▼
                  VALIDATION
```
