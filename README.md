# Modélisation statistique, l'essentiel — 8 et 9 octobre 2026 (classe virtuelle)

Formateur : Matthieu Falce, matthieu@falce.net

Page de la formation (horaires, visio, accès aux postes distants, ressources) : https://matthieu-falce.notion.site/Orsys-STA-Octobre-2026-3f3fd641a63681b4b8d4ef81f473a5e5

Ce dossier est mis à jour en continu pendant les deux jours : `git pull` (ou Code › Download ZIP) pour récupérer ce qui a été tapé en cours.

## Contenu de ce dossier

| Fichier | Quoi | Quand |
|---|---|---|
| `support_cours.pdf` | le support de cours, une slide par page, liens cliquables | à garder ouvert pendant les deux jours |
| `support_cours_impression.pdf` | le même support, deux slides par page, pour l'impression (sans liens) | si vous préférez le papier |
| `sujets_tp.pdf` | les énoncés des travaux pratiques | jour 1 et jour 2 |
| `fiche_guide_decision.pdf` | quelle question, quel test, quelle fonction Excel ou R, quelle phrase | à imprimer ou garder ouverte, on s'en sert en continu |
| `fiche_vocabulaire_rapport.pdf` | ce qu'on écrit et ce qu'on n'écrit pas dans un rapport | jour 2, pour l'étape finale |
| `medias/` | les données des TP (fichiers CSV) | voir ci-dessous |
| `echantillonnage.html` | une animation à ouvrir dans un navigateur, hors ligne : la moyenne d'un échantillon, mille fois | jour 1 après-midi |
| `risques.html` | une seconde animation, même principe : mille médicaments testés, faux positifs et faux négatifs | jour 2 matin |
| `alpha_beta.html` | le seuil de décision et les deux risques, avec le nombre de patients et la variabilité | jour 2 matin |

Les corrections sont ajoutées dans ce dossier à la fin de la formation.

## À installer avant le 8 octobre

1. **Excel** (ou LibreOffice Calc). Les fonctions sont citées en français (`MOYENNE`, `ECARTYPE.STANDARD`, `FREQUENCE`, `DROITEREG`…). Si votre Excel est en anglais, dites-le au début de la formation, la traduction est immédiate.
2. **R et RStudio**, utilisés le deuxième jour :
   - R : https://cran.r-project.org (choisir votre système, puis « base » sous Windows)
   - RStudio Desktop : https://posit.co/download/rstudio-desktop/
   - Test : lancer RStudio, taper `t.test(rnorm(30))` dans la console et appuyer sur Entrée. Si un résultat s'affiche, tout est prêt.
   - Sur un poste d'entreprise verrouillé, demandez l'installation à votre service informatique dès maintenant. Si c'est impossible, https://webr.r-wasm.org fonctionne dans un navigateur sans rien installer.
3. **Deux écrans ou un grand écran** si possible : la visioconférence d'un côté, Excel ou R de l'autre.

## Les données

Les fichiers CSV du dossier `medias/` utilisent le point-virgule comme séparateur et la virgule comme décimale : ils s'ouvrent directement dans un Excel en français. Les fichiers du dossier `medias/descriptives/` et `medias/testsHypotheses/` sont volontairement plus capricieux (c'est le premier exercice).

Le fil rouge des deux jours est une boutique en ligne (`medias/filRouge/`) :
- `commandes.csv` : 2000 commandes de l'année
- `visitesAB.csv` : 4000 visites pendant un test A/B de la page d'accueil
- `caHebdo.csv` : budget publicitaire et chiffre d'affaires de 52 semaines

## Avant de commencer, une question

Pensez à **un chiffre que vous avez dû défendre récemment** dans votre travail (un taux, une moyenne, une prévision, un écart entre deux groupes). On en parlera au tour de table du premier matin, et il servira d'exemple pendant les deux jours.
