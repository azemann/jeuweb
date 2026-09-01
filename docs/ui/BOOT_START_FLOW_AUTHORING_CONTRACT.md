# Contrat auteur — Boot, Start Flow et typographie d'interface

## Intention

Le démarrage doit installer l'univers avant de présenter des actions simples,
lisibles au clavier, à la manette et à la souris. Les images composent le décor
et les cadres ; Godot reste autoritaire pour le texte, le focus, les actions,
les transitions et l'accessibilité.

## Autorités

| Information | Autorité | Point d'édition |
|---|---|---|
| routage entre écrans | `AppFlowConfig` | `app/app_flow_config.tres` |
| durée et couleur des fondus | `AppFlowConfig` | groupe `Transitions` |
| choix des illustrations et ornements | `BootStartFlowTheme` | `ui/flows/themes/*.tres` |
| texte et composition d'un écran | scène `.tscn` concernée | SceneTree et Inspector |
| style typographique transversal | `game_ui_theme.tres` | variations du `Theme` |
| état de focus courant | `Control` et signaux `focus_entered` | runtime natif Godot |
| source artistique | `pipeline/assets/sources/` | pipeline uniquement |
| bitmap runtime publié | `art/ui/flows/` | sortie générée, non éditée |

Une illustration ne possède jamais un libellé, un bouton ou un état de focus.
Le texte visible reste un `Label` ou un `Button` natif afin de permettre une
future localisation sans régénération artistique.

Un cadre illustré conserve son ratio source. Sa zone de texte correspond à son
ouverture intérieure, jamais à tout son rectangle englobant. Un bouton placé
dans un cadre fortement décoré emploie une variation sans cartouche opaque : le
cadre fournit déjà la masse et le matériau.

## Correspondance visuelle

| Élément | Signification |
|---|---|
| emblème circulaire | identité de l'univers et de la faction Vacuum |
| plaque horizontale | support d'un titre Godot, jamais logo textuel raster |
| cadre vertical | contenant décoratif des actions du menu |
| flèche magenta lumineuse | action possédant réellement le focus |
| cadenas | contenu indisponible, lorsqu'une vraie règle l'établira |
| lampes lime/magenta | vocabulaire futur d'état, sans usage décoratif arbitraire |
| carte et six marqueurs | vocabulaire du futur Mission Select |

La carte, les marqueurs, le cadenas et les lampes sont publiés et exposés dans
la Resource, mais aucune sélection de mission fictive n'est créée. Leur usage
attend une véritable autorité de catalogue, de déverrouillage et de progression.

## Hiérarchie typographique

`game_ui_theme.tres` expose des variations sémantiques :

- `DisplayTitleLabel` pour l'identité principale d'un écran ;
- `SectionTitleLabel` pour un titre de section ;
- `CaptionLabel` pour une indication secondaire ;
- `HUDValueLabel` pour une valeur compacte ;
- `HUDObjectiveLabel` pour une consigne pendant l'action ;
- `NotificationLabel` pour chargement, erreur et résultat ;
- `CompactButton` et `MobileActionLabel` pour les contrôles contraints.

Les textes posés sur une illustration chargée possèdent un contour opaque. Les
titres et notifications sont centrés dans leur plaque ; les valeurs HUD suivent
la géométrie de leur jauge ; un alignement décentré doit servir une composition
visible et non résulter d'offsets improvisés.

Un indicateur de focus masqué conserve sa place dans le Container grâce à son
alpha. Le rendre `visible = false` est interdit lorsque cela décale les autres
libellés. Une passe artistique est validée sur une capture du renderer réel en
1280 × 720 ; la seule validation headless ne suffit pas à juger le ressenti.

## Scènes canoniques

```text
BootFlow
├── Backdrop
├── Shade
├── Identity
│   ├── Emblem
│   └── TitlePlate + Label
├── ContinueHint
├── AutoContinueTimer
└── AnimationPlayer

StartFlow
├── Backdrop
├── Overlay
├── MenuComposition
│   ├── TitlePlate + Labels
│   └── MenuFrame
│       └── Rows
│           ├── FocusIndicator
│           └── Button
└── AnimationPlayer
```

Les scènes émettent seulement des intentions. Elles ne choisissent jamais
l'écran suivant et ne connaissent pas les chemins des autres écrans.

## Chargement en mission

Le `MissionHUDTheme` possède le background de chargement de la mission. Le HUD
compose par-dessus une ombre, une plaque, un `LoadingTitleLabel` et un
`LoadingLabel`. La map ou le
pipeline ne possède ni le message courant ni l'état de visibilité ; ceux-ci
restent pilotés par les signaux du `MissionMapHost2D`.

## Validation

`boot_start_flow_contract_test.gd` vérifie la Resource, les dix-neuf sorties,
la séparation emblème/texte, le focus réel, les variations typographiques, le
loading composé et la préparation sans faux runtime du futur Mission Select.
