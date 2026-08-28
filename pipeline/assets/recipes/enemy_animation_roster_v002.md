# Recette — bestiaire ennemi animé v002

## Intention

Remplacer les poses v001 trop proches, mal séparées ou incohérentes par une
passe d'animation complète pour les cinq archétypes consommables par la mission
Côte toxique : Vacuum Trooper, Siphoner/Grunt, Scout Drone, Brute/Boss et
Hatchling Saboteur.

La règle de sélection est fonctionnelle avant d'être illustrative : identité
stable, silhouette lisible, phase biomécanique distincte, root constant, aucun
membre ou équipement recomposé entre deux poses et aucun fragment de cellule
voisine.

## Mode de génération

- outil : ImageGen intégré à Codex ;
- mode : édition/dérivation avec conservation d'identité depuis les sources
  locales v001 ;
- sortie : une bande horizontale de quatre poses par action sur fond cyan
  uniforme `#00FFFF` ;
- orientation : profil droit constant ;
- exclusions : texte, grille peinte, décor, ombre, recouvrement, coupe au bord.

Chaque prompt final répétait l'inventaire visuel exact de l'archétype, la
caméra, la direction, le fond et les marges, puis décrivait explicitement les
quatre phases demandées.

## Poses finales

### Mouvement

- unités terrestres : contact A, compression/passage A, contact B,
  montée/passage B ;
- Vacuum Trooper : cycle complet de huit poses, réparti sur deux bandes ;
- Drone : point bas, montée, point haut, descente, avec deux turbines et deux
  dérives visibles dans chaque case.

### Attaque

- anticipation ;
- charge/télégraphe ;
- phase active avec effet entièrement contenu ;
- recul/récupération sans effet résiduel ambigu ;
- Vacuum Trooper : huit poses réparties sur deux bandes pour conserver sa
  cadence historique.

### Impact

- contact du projectile ;
- compression/recul ;
- déséquilibre ;
- récupération non létale, sans pièce détachée ni transformation.

### Mort

- rupture létale ;
- effondrement ;
- impact au sol ;
- dépouille finale immobile. Chaque pose descend, aucune ne revient debout.

## Itérations rejetées

- premier mouvement du Drone : une turbine disparaissait selon la case ;
- premier hit du Drone : inventaire des turbines discontinu ;
- première attaque du Boss : rayon actif coupé par la frontière droite.

Ces bandes ne sont ni publiées ni consommées. Les secondes versions du Drone
imposent deux turbines et deux dérives comptables dans chaque pose. La seconde
attaque du Boss utilise un rayon court avec pointe et marge cyan visibles.

## Normalisation déterministe

```bash
python3 pipeline/assets/tools/process_enemy_animation_roster_v002.py
```

Le processeur :

1. découpe chaque bande en quatre cellules proportionnelles ;
2. extrait l'alpha depuis le fond cyan ;
3. supprime les seuls composants détachés qui touchent une frontière ;
4. applique une échelle commune par action ;
5. aligne les unités terrestres sur leur root et le Drone sur son centre de vol ;
6. construit sept atlas runtime, cinq feuilles de revue, cinq aperçus animés et
   le rapport QA des 88 poses.

## Correspondance auteur/runtime

- autorité créative : sources ImageGen versionnées sous
  `pipeline/assets/sources/imagegen/enemies/` ;
- autorité de transformation :
  `pipeline/assets/tools/process_enemy_animation_roster_v002.py` ;
- livrables runtime : PNG v002 sous `res://art/` ;
- point d'édition Godot : `SpriteFrames` des cinq scènes ennemies ;
- correspondance : lignes d'atlas `move/attack/hit/death` vers animations
  `walk/attack/hit/death` ;
- validation : QA pipeline, test de contrat ennemi et import headless Godot.
