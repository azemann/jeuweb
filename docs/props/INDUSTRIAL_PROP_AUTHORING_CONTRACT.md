# Contrat auteur des props industriels

## Autorités

- landmark ou obstacle statique : `WorldPropData` puis instance `WorldProp2D` ;
- soin, ravitaillement ou armurerie : `ServiceStationData` puis
  `ServiceStation2D` ;
- mine : `ProximityMineData`, son état armé restant dans `ProximityMine2D` ;
- objet destructible explosif : `ExplosivePropData`, dont `prop_id` identifie
  ce qui explose et `explosion_data.explosion_id` identifie comment ça explose ;
- évent : `HazardData`, exécutée par `DamageHazard2D` ;
- barricade : `GroundPieceDefinition`, exécutée par `GroundPiece2D` en mode
  Breakable ;
- placement, échelle et orientation : scène maîtresse de mission.

Un prop ne devient pas une catégorie générique lorsqu'un contrat existant le
décrit déjà. La barricade appartient ainsi au Ground Kit et l'évent au système
de dangers. Le projecteur et le relais utilisent seuls le contrat WorldProp.

## Workflow auteur

1. Publier le bitmap traçable sous `art/`.
2. Choisir le contrat existant correspondant à sa fonction.
3. Créer ou assigner sa Resource dans l'Inspector.
4. Instancier la scène canonique sous `Gameplay/Interactions`, `Hazards` ou
   `GroundPieces` selon sa responsabilité.
5. Régler uniquement le Transform final dans la scène maîtresse.

Les quatre armureries réutilisent le bitmap unique du casier mais possèdent
quatre `ServiceStationData` : cette variation de contenu n'est pas un doublon
d'asset et ne recopie aucune donnée d'arme.

Le même principe vaut pour les objets explosifs : plusieurs occurrences peuvent
instancier la même scène canonique `ExplosiveProp2D`, mais choisir des
`ExplosivePropData` distinctes dans l'Inspector. Le `prop_id` décrit l'objet ou
contenant explosif ; le `ExplosionData.explosion_id` décrit le profil de
détonation.
`AuthorPreview` permet de vérifier cette correspondance directement dans la
vue 2D pendant l'édition.

## Validation

`industrial_toxic_expansion_contract_test.gd` protège Resources, scènes et
imports. `map_contract_test.gd` protège leur placement fonctionnel dans les
trois actes de Côte toxique.
