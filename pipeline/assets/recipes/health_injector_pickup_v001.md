# Recette — injecteur de soin v001

## Autorités

- source candidate : megapack industriel toxique v001 ;
- normalisation reproductible : `process_health_injector_pickup.py` ;
- livrable runtime : `art/pickups/health-injector-v001.png` ;
- effet gameplay : `PickupData.tres`, jamais le bitmap.

## Décision visuelle

La candidate `health-injector-pickup-source-v001.png` est retenue comme premier
pickup : silhouette médicale lisible, croix verte, liquide toxique et accents
magenta cohérents avec Côte toxique. Son canal alpha original est valide ; le
fond noir vu dans certains visualiseurs correspond aux pixels RGB masqués par
alpha zéro et n'est pas publié comme décor.

Deux essais ImageGen de nouvelle extraction alpha ont été contrôlés puis
rejetés : ils n'amélioraient pas le masque et altéraient légèrement le dessin.
La source originale reste donc souveraine.

## Normalisation

```bash
python3 pipeline/assets/tools/process_health_injector_pickup.py
```

Le processeur découpe la silhouette au seuil alpha 16, la place dans une zone
sûre 168 × 144 sur un canevas transparent 192 × 192, puis publie export, copie
runtime et rapport QA avec hashes.
