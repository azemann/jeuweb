# Recherche — architectures adaptées à notre jeu

Recherche effectuée le 27 août 2026 à partir de documentations officielles
Godot, Unreal Engine et Unity.

## Conclusion

Il n'existe pas une architecture universellement supérieure. La meilleure
architecture est celle qui épouse les primitives du moteur, le workflow des
auteurs, le volume de contenu et les contraintes de performance réelles.

Pour notre run-and-gun 2D solo, l'architecture cible reste :

```text
scènes composées
→ Nodes natifs
→ Resources éditables
→ composants locaux
→ signaux d'événements
→ spawners et bindings explicites
→ code minimal
→ validation des contrats
```

Un ECS intégral, une architecture Clean complète ou une forêt de managers
ajouteraient aujourd'hui plus de traduction que de valeur.

## Enseignements des moteurs

### Godot : scène déclarative, script comportemental

Godot distingue la scène, qui déclare une composition de Nodes, du script, qui
ajoute le comportement impératif. Sa documentation recommande les scènes pour
les concepts spécifiques au jeu et souligne qu'elles restent plus faciles à
suivre et modifier que des arbres construits entièrement par code.

Application au projet : `PlayerCharacter2D.tscn`, les scènes ennemies,
`GroundPiece2D.tscn`, les projectiles et les explosions doivent rester des
assemblages visibles. Leurs scripts ne doivent pas reconstruire leur arbre.

### Godot : scènes autonomes et dépendances fournies par le parent

La recommandation officielle est de limiter les dépendances d'une sous-scène
sur son environnement. Lorsqu'elle a besoin du monde extérieur, un parent de
haut niveau doit lui fournir la référence ou la donnée.

Application : les scènes d'acteurs possèdent leurs composants ; les spawners
leur donnent position, profil et propriétaire ; la racine de mission fournit
les branches runtime. Une scène réutilisable ne recherche pas arbitrairement
un cousin avec plusieurs `get_parent()`.

### Godot : Nodes pour le comportement, Resources pour les données

La documentation Godot définit les Nodes comme porteurs de fonctionnalités et
les Resources comme conteneurs de données. Les Resources personnalisées sont
sérialisées nativement, partageables et éditables directement dans
l'Inspector.

Application : `WeaponData`, `ProjectileData`, `EnemyArchetypeProfile` et les
définitions de terrain sont la bonne direction. Les PV actuels, cooldowns et
directions restent dans les composants runtime, jamais dans les `.tres`
partagées.

### Godot : signaux pour les événements

Les signaux permettent à un objet de réagir à un autre sans référence directe.
Ils correspondent au patron Observer natif de Godot.

Application : `died`, `health_changed`, `map_loaded` ou `terrain_carved` sont
des événements. `apply_damage()`, `load_map()` et `fire()` sont des commandes
intentionnelles et restent des appels directs.

### Godot : Autoloads rares

Godot avertit que l'accès global élargit fortement la zone à inspecter lors
d'un bug. Les Autoloads conviennent aux systèmes réellement larges qui gèrent
leur propre état sans envahir celui des scènes.

Application : aucun Autoload n'est requis pour une arme, un ennemi, la caméra,
le terrain ou l'interface de mission. Une future sauvegarde ou des réglages
persistants pourront justifier ce cycle de vie global.

### Unreal : framework de gameplay et responsabilités explicites

Le Gameplay Framework d'Unreal sépare monde, règles de partie, état de partie,
contrôleur, représentation physique, caméra et interface. Les Actors sont
ensuite construits avec des composants spécialisés.

La leçon transférable n'est pas de copier ses classes, mais de distinguer :

- les règles d'une mission ;
- l'état courant de la session ;
- l'acteur physique ;
- ce qui le commande ;
- sa présentation et son interface.

Notre `MissionMapDefinition` ne doit donc pas devenir l'état runtime de la
mission. Lorsque victoire, défaite et objectifs apparaîtront, ils mériteront
une responsabilité visible séparée, probablement `MissionSession2D` ou
`MissionRules2D` dans l'arbre, pas un Autoload.

### Unreal et Unity : contenus configurables comme assets de données

Les Data Assets d'Unreal et les ScriptableObjects de Unity jouent un rôle
proche des Resources Godot : conserver des données partagées, modifiables par
les auteurs, indépendamment des occurrences runtime.

Cette convergence confirme notre séparation :

```text
Resource de définition
→ scène canonique
→ composants et état runtime
→ présentation
```

### ECS : utile seulement lorsque le volume le justifie

Dans l'ECS de Unity, une entité est essentiellement un identifiant, les
composants contiennent les données et les systèmes traitent des ensembles de
composants. Cette organisation est excellente pour de très grands volumes
homogènes et des traitements orientés données.

Notre jeu ne doit pas devenir un ECS par principe. Les scènes Godot restent
plus productives pour quelques dizaines d'acteurs riches. Une approche
orientée données ne deviendrait pertinente que pour un système isolé et
mesuré : milliers de particules, débris ou projectiles simultanés.

## Architecture cible du projet

```text
AppFlow
├── ScreenHost
└── MissionRuntime
    ├── MissionMapHost2D
    │   └── MissionMapRoot2D
    │       ├── Visual
    │       ├── Gameplay              # authoring
    │       ├── DestructibleTerrain   # runtime local à la map
    │       └── Actors                # instances runtime
    ├── MissionActorSpawner2D
    ├── MissionEnemySpawner2D
    ├── MissionProjectileSpawner2D
    ├── MissionCameraRig2D
    └── Interface
```

Chaque acteur suit ensuite :

```text
CharacterBody2D
├── CollisionShape2D
├── Hurtbox
├── Components
│   ├── Movement / Patrol
│   ├── Health
│   ├── Weapon / Attack
│   ├── Grounding
│   └── Presentation
└── Presentation
    ├── AnimatedSprite2D
    ├── AnimationPlayer
    ├── AudioStreamPlayer2D
    └── VFX sockets
```

## Styles architecturaux retenus

| Style | Usage chez nous | Décision |
|---|---|---|
| Scene/component | Acteurs, effets, terrain, écrans | architecture principale |
| Data-driven | Profils, définitions, catalogues et bindings | obligatoire pour le contenu variable |
| Event-driven | Réactions locales par signaux | oui, avec événements au passé |
| State machine | Comportements comportant plusieurs états exclusifs | locale à l'acteur, quand nécessaire |
| Framework hiérarchique | Flux application et règles de mission | léger et visible dans le SceneTree |
| ECS/data-oriented | Très grands volumes homogènes | uniquement après mesure d'un besoin réel |
| Clean Architecture complète | Services indépendants du moteur | non pour le gameplay courant |
| Singleton/manager global | Sauvegarde, réglages persistants éventuels | exception, jamais raccourci d'accès |

## Écarts et prochaines améliorations

1. Ajouter une responsabilité visible pour les règles et l'état d'une mission
   lorsque victoire, défaite et respawn seront implémentés.
2. Conserver les ennemis derrière `EnemyCatalog` et des scènes canoniques ; ne
   jamais mettre de `match archetype_id` dispersé dans les spawners.
3. Ajouter sons et VFX à chaque scène concernée plutôt qu'un AudioManager
   prématuré.
4. Employer `AnimationPlayer` pour les fenêtres temporelles déterministes :
   tir, attaque ennemie, rupture de coque et éjection du pilote.
5. N'introduire pooling, streaming ou ECS qu'après profilage d'un problème
   mesurable.
6. Mettre en place un véritable historique de version lorsque le workflow le
   permettra ; les fichiers texte Godot sont conçus pour être fusionnables.

## Questions obligatoires pour une nouvelle classe

1. Quelle information ou quel comportement en est l'autorité ?
2. Son cycle de vie est-il celui d'une Resource, d'une scène ou d'une session ?
3. Où l'auteur la voit-il et la règle-t-il dans Godot ?
4. Est-elle un contenu, une occurrence, une présentation ou une orchestration ?
5. Quelle dépendance doit être injectée par le parent ?
6. Quel signal expose ses événements sans créer de dépendance inverse ?
7. Quel contrat vérifiera automatiquement que cette frontière reste vraie ?

## Sources officielles

- [Godot — Scene organization](https://docs.godotengine.org/en/latest/tutorials/best_practices/scene_organization.html)
- [Godot — When to use scenes versus scripts](https://docs.godotengine.org/en/stable/tutorials/best_practices/scenes_versus_scripts.html)
- [Godot — Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot — Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Godot — Autoloads versus regular nodes](https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_regular_nodes.html)
- [Godot — Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)
- [Godot — Version control systems](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html)
- [Unreal Engine — Gameplay Framework](https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-framework-in-unreal-engine)
- [Unreal Engine — Data Assets](https://dev.epicgames.com/documentation/en-us/unreal-engine/data-assets-in-unreal-engine)
- [Unity — ScriptableObject](https://docs.unity3d.com/6000.1/Documentation/Manual/class-ScriptableObject.html)
- [Unity Entities — Entity Component System concepts](https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/concepts-intro.html)

