# Recette kit de sol Côte toxique v001

## Première pièce

`natural_ledge_medium_v001` est une plateforme naturelle moyenne, raccordable
par chevauchement et conçue pour devenir Permanent, Carvable ou Breakable dans
l'Inspector de son instance Godot.

## Référence

`art/concepts/da-03-environment-destruction.png` a servi uniquement de référence
de style, palette, matière et silhouette. La planche assemblée n'est jamais
découpée ou consommée au runtime.

## Prompt ImageGen

```text
Use case: stylized-concept
Asset type: isolated 2D side-scrolling game terrain piece, production source
Input image: use the supplied Côte toxique environment/destruction board only
as a style, palette, material, and silhouette reference; do not copy its
assembled scene or beige background
Primary request: one isolated medium natural terrain ledge for a side-scrolling
run-and-gun game
Subject: a single connected wide chunk with a broad nearly horizontal walkable
top and an irregular toxic dark-earth underside hanging downward; embedded oily
pipes and a few acid-green roots; no detached parts
Style/medium: richly painted 2D game asset, strict side view, thick expressive
black outlines, extravagant military-cartoon rendering
Composition/framing: one centered object only, wider than tall, generous
transparent padding on all sides, every visible pixel away from canvas edges;
the top walking surface remains unoccluded and easy to read
Color palette: dark soil, oily anthracite and olive metal, acid green growth,
very small magenta accents
Constraints: genuinely transparent native alpha background; one connected
silhouette; no characters, enemies, weapons, explosion, labels, ground plane,
cast shadow, checkerboard, opaque backdrop, watermark or detached debris
```

La première génération a produit un damier opaque RGB et reste enregistrée
comme source rejetée v001. Une extraction ciblée par ImageGen a produit la
source alpha v002 sans écraser l'essai.

## Normalisation

```bash
python3 pipeline/assets/tools/process_ground_piece_candidates.py
python3 pipeline/assets/tools/validate_ground_piece_candidates.py
```

Le processeur retire les alpha inférieurs ou égaux à 16/255, normalise sur un
canevas transparent de 768 × 384 et conserve le pivot de surface `[384, 64]`.
Il ne publie rien automatiquement sous `art/`.
