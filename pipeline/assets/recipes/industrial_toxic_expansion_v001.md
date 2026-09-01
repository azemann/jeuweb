# Industrial Toxic Expansion v001

Lot dérivé publiant uniquement les 27 sources absentes du runtime. La matrice
anti-doublon du megapack fait autorité sur la sélection.

- objets isolés : recadrage alpha, mise à l'échelle uniforme et placement sur
  canevas fixe selon leur famille ;
- impacts : découpage source 3×2 puis normalisation de chaque cellule sur
  192×160, atlas final 576×320 ;
- aucune génération nouvelle et aucune modification de dessin ;
- sources immuables sous le lot megapack, exports reproductibles sous
  `pipeline/assets/exports/industrial_toxic_expansion_v001/` ;
- copies runtime versionnées sous `art/` uniquement après cette sélection.

Commande : `python3 pipeline/assets/tools/process_industrial_toxic_expansion.py`.
