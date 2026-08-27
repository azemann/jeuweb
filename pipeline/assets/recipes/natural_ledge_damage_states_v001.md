# Corniche naturelle — états de dégâts v001

## Intention

Créer deux remplacements visuels alignés sur la texture intacte : un état
`damaged` encore praticable et un état final `destroyed`. Les trois images
partagent un canevas 768 × 384 et le pivot de surface `[384, 64]`.

## Prompts ImageGen

`damaged` : éditer la corniche exacte vers environ un tiers de vie, avec
cratères, fissures, morceaux manquants et tuyaux cabossés ou fuyants, tout en
conservant une plateforme connectée et majoritairement praticable.

`destroyed` : éditer la corniche exacte après tirs et explosions, avec grands
morceaux arrachés, tuyaux brisés, supports tordus et ruine clairement non
praticable, sans perdre l'identité de l'asset.

Contraintes communes : style arcade peint identique, palette Côte toxique,
aucun personnage, texte, UI ou nouvel environnement, composition et pivot
stables, fond alpha demandé.

## Traitement

Les deux générations ont livré un fond RGB (noir pour `damaged`, blanc pour
`destroyed`). Le processeur retire uniquement le fond similaire connecté aux
bords, protège les pixels sombres/clairs enclavés dans le sujet, recadre puis
normalise sur le canevas canonique. Les exports restent candidats sous
`pipeline/assets/exports/` jusqu'à validation humaine.

Une correction ImageGen ciblée demandant uniquement l'extraction du blanc a
été rejetée : elle a redessiné l'asset et ajouté un halo brun-vert opaque. Cette
sortie n'est pas conservée ; l'extraction déterministe reste l'autorité.
