# Recherche de production — run-and-gun

Recherche effectuée le 26 août 2026 pour guider la boucle jouable du projet.
Les références servent à extraire des principes, jamais à recopier une œuvre.

## Principes retenus

1. **Commandes simples, réponse immédiate.** Les développeurs de Metal Slug
   visaient une action accessible, rapide et compréhensible d'un regard. Le
   premier tir doit donc fonctionner avant l'inventaire ou les variantes.
2. **Le projectile doit avoir vitesse, poids et conséquence.** Les interviews
   Metal Slug insistent sur les balles rapides, le métal, la force et la
   destruction. Chaque arme aura cadence, vitesse, silhouette, impact et recul
   distincts, tous réglables par Resource.
3. **Lisibilité avant surcharge.** Joueur, ennemis, projectiles et dangers
   doivent rester identifiables instantanément. Les foregrounds et VFX ne
   peuvent pas cacher le couloir de jeu.
4. **Le monde doit sembler vivant.** Les animations non fonctionnelles donnent
   une existence aux machines et ennemis, mais les poses de gameplay restent
   prioritaires et leurs timings appartiennent aux AnimationPlayer.
5. **Une nouvelle capacité transforme aussi les niveaux et ennemis.** L'équipe
   de Contra 4 rappelle qu'un mouvement ou une arme change directement le
   level design, les ennemis et les boss. Chaque ajout devra donc être testé
   dans une rencontre auteur, pas seulement dans une scène isolée.
6. **Progression contrôlée par le joueur.** Notre caméra avance avec le joueur
   plutôt qu'en défilement forcé. Les segments enchaînent introduction,
   combinaison et climax, avec respiration entre les rencontres.
7. **Difficulté réglée sans dégrader le contrôle de base.** Les paramètres de
   santé, cadence ennemie, checkpoints et modes pourront élargir l'accès ; la
   réponse des commandes ne doit pas devenir molle pour faciliter le jeu.
8. **Rejouabilité après une première boucle claire.** Score, secrets, routes et
   variantes viendront après une mission agréable à parcourir et à tirer.

## Correspondance Godot appliquée

La documentation Godot recommande un projectile `Area2D` indépendant du joueur
et une demande de tir transmise par signal à la scène principale. Le projet
applique donc :

```text
Input Map
  → PlayerWeaponComponent + WeaponData
  → signal projectile_requested
  → MissionProjectileSpawner2D
  → Projectile2D + ProjectileData
  → collision / impact / damage
```

Le joueur ne connaît ni la carte ni le conteneur runtime des projectiles. La
scène de mission orchestre leur apparition sous `Runtime/Projectiles`.

## Références

- [Godot — Instancing with signals, shooting example](https://docs.godotengine.org/en/stable/tutorials/scripting/instancing_with_signals.html)
- [Godot — Using Area2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html)
- [Metal Slug — collection d'entretiens développeurs traduits](https://shmuplations.com/metalslug/)
- [SNK developers on Metal Slug machinery and animation](https://www.siliconera.com/snk-developers-talk-about-how-some-of-the-classic-arcade-games-were-made/)
- [Contra 4 developer interview](https://contra.kontek.net/features/interview/7-19-07-contra4.htm)
- [Contra: Operation Galuga postmortem](https://www.nintendojo.com/news/single-stories/nintendojo-interview-contra-operation-galuga-post-mortem)
- [GDC — Boss Battle Design Fundamentals](https://gdcvault.com/play/1024921/Boss-Up-Boss-Battle-Design)

## Première cible de sensation

Le canon v001 tire automatiquement des projectiles rapides, francs et très
lisibles. La première tranche valide : cadence, direction depuis le `Muzzle`,
indépendance après le tir, collision monde, contrat de dégâts et impact visuel.
Audio, recul avancé, secousse caméra et ennemis complets viendront ensuite.
