# Contrat de mémoire du projet

Ce dépôt doit pouvoir être repris après une pause sans dépendre de la mémoire
d'une conversation.

Après chaque tranche de travail significative, mettre à jour :

1. `docs/PROJECT_STATE.md` : état vrai, systèmes fonctionnels, limites et
   prochaine action ;
2. `docs/WORKLOG.md` : actions réalisées, fichiers importants et validations ;
3. `art/ASSET_MANIFEST.md` : provenance, intention, version et intégration de
   chaque asset créé ou importé ;
   les sources et recettes sont enregistrées sous `pipeline/assets/`, jamais
   mélangées aux livrables `res://art/` ;
4. le contrat auteur du système concerné lorsqu'une règle d'architecture
   change ;
5. les tests headless qui protègent les nouveaux invariants ;
6. Git : un commit cohérent après validation de la tranche.

Cette règle s'applique à toute la production, pas uniquement à la fondation :
gameplay, maps, ennemis, armes, UI, audio, outils, pipeline et direction
artistique. Une décision créative structurante doit être enregistrée même si
elle ne produit pas immédiatement de code.

## Contenu minimal d'une entrée de travail

- intention ou décision prise ;
- fichiers, scènes et Resources créés ou modifiés ;
- autorité des nouvelles données ;
- intégration visible dans Godot ;
- limites ou dette laissées volontairement ;
- validation réellement exécutée ;
- prochaine action recommandée.

Pour chaque nouveau système important, enregistrer également :

- l'autorité de chaque information structurante ;
- le point d'édition auteur dans Godot ;
- les correspondances avec les autres systèmes ou outils ;
- le contrat runtime, le contrat auteur et le contrat de validation ;
- le test architectural qui empêche ces choix de dériver.

## Reprise d'une session

Lire dans cet ordre :

1. `docs/PROJECT_STATE.md` ;
2. la dernière entrée de `docs/WORKLOG.md` ;
3. le contrat du système à modifier ;
4. `art/ASSET_MANIFEST.md` si le travail concerne la DA ;
5. exécuter les commandes de validation indiquées dans l'état courant.

Le fichier `README.md` à la racine rappelle ce parcours de reprise.

Ne jamais déclarer une fonctionnalité terminée uniquement parce qu'elle existe
dans un script : son statut doit correspondre à ce qui est visible dans Godot
et à ce que les tests vérifient.
