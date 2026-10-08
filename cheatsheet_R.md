# R pour les débutants : l'essentiel pour les deux jours

Une ligne par test. Tout ce qui est ici est utilisé dans les TP ; le reste de R peut attendre.

## 1. Se repérer dans RStudio

- **Console** (en bas à gauche) : on tape une commande, Entrée, le résultat s'affiche.
- **Script** (Fichier › Nouveau fichier › R Script) : on écrit les commandes, `Ctrl+Entrée` (ou `Cmd+Entrée`) exécute la ligne où est le curseur. Préférer le script : on garde la trace.
- `?t.test` ouvre l'aide d'une fonction ; `#` commence un commentaire.
- Le dossier de travail : Session › Set Working Directory › To Source File Location, ou `setwd("C:/Users/moi/sta-octobre-2026")`. `getwd()` dit où on est.

## 2. Variables et vecteurs

```r
x = 49.12            # un nombre (le = et le <- sont équivalents)
nom = "Colissimo"    # du texte, entre guillemets
ok = TRUE            # un booléen (TRUE / FALSE, en majuscules)

paniers = c(31.5, 48, 120.9, 27)   # c() fabrique un vecteur (une colonne)
paniers[2]           # le 2e élément : 48 (ça commence à 1, pas à 0)
paniers[paniers > 40]   # les éléments qui vérifient une condition
length(paniers)      # combien d'éléments
1:10                 # les entiers de 1 à 10
seq(0, 1, 0.25)      # 0, 0.25, 0.5, 0.75, 1
```

Les opérations s'appliquent à tout le vecteur d'un coup : `paniers * 1.2`, `log(paniers)`, `paniers - mean(paniers)`.

## 3. Charger les données du cours

Les CSV du dossier `medias/` sont « à la française » : séparateur `;`, décimale `,`.

```r
commandes = read.table("medias/filRouge/commandes.csv", sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")
visites   = read.table("medias/filRouge/visitesAB.csv",  sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")
ca        = read.table("medias/filRouge/caHebdo.csv",    sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")
```

- `header = TRUE` : la première ligne contient les noms de colonnes.
- `fileEncoding = "UTF-8-BOM"` : les fichiers du cours (sortis d'Excel) commencent par un marqueur invisible ; sans cette option, la première colonne s'appelle `X.U.FEFF.id_commande` au lieu de `id_commande`.
- Fichier anglais (`,` et `.`) : `read.csv("fichier.csv")` suffit.
- Si R ne trouve pas le fichier : `file.choose()` ouvre une fenêtre et renvoie le chemin.

## 4. Regarder un tableau de données (data frame)

```r
head(commandes)        # les 6 premières lignes
str(commandes)         # une ligne par colonne : type et premières valeurs
nrow(commandes)        # nombre de lignes ; ncol() pour les colonnes
names(commandes)       # les noms des colonnes
summary(commandes)     # min, quartiles, médiane, moyenne, max de chaque colonne

commandes$montant_eur              # une colonne, c'est un vecteur
commandes[commandes$canal == "Email", ]          # les lignes où canal vaut Email
chrono = commandes[commandes$transporteur == "Chronopost", ]
commandes$satisfait = commandes$satisfaction >= 4  # créer une colonne
```

Lire `tableau[lignes, colonnes]` : avant la virgule les lignes, après la virgule les colonnes, vide = toutes.

## 5. Décrire

```r
mean(commandes$montant_eur)      # moyenne
median(commandes$montant_eur)    # médiane
sd(commandes$montant_eur)        # écart-type (divise par n-1, comme ECARTYPE.STANDARD)
var(commandes$montant_eur)       # variance
quantile(commandes$montant_eur)                      # min, Q1, médiane, Q3, max
quantile(commandes$montant_eur, c(0.025, 0.975))     # les centiles qu'on veut
range(commandes$montant_eur)     # min et max

table(commandes$canal)                          # effectifs d'une variable qualitative
prop.table(table(commandes$canal))              # fréquences
table(commandes$transporteur, commandes$satisfait)   # tableau croisé
tapply(commandes$montant_eur, commandes$canal, mean) # une moyenne par groupe
aggregate(montant_eur ~ canal, data = commandes, FUN = mean)   # pareil, en tableau
```

Valeurs manquantes (`NA`) : `mean(x, na.rm = TRUE)` les ignore ; `sum(is.na(x))` les compte.

## 6. Graphiques de base

```r
hist(commandes$montant_eur)                       # histogramme
boxplot(commandes$montant_eur)                    # boîte à moustaches
boxplot(montant_eur ~ canal, data = commandes)    # une boîte par groupe
barplot(table(commandes$canal))                   # diagramme en bâtons
plot(ca$budget_pub_eur, ca$chiffre_affaires_eur)  # nuage de points
abline(lm(chiffre_affaires_eur ~ budget_pub_eur, data = ca))   # la droite dessus
```

La formule `y ~ x` se lit « y expliqué par x » : on la retrouve partout (boxplot, t.test, aov, lm).

## 7. Lois : calculer et simuler

```r
pnorm(56, mean = 60, sd = 2)             # P(X < 56) pour une normale N(60, 2²)
pnorm(64, 60, 2) - pnorm(56, 60, 2)      # P(56 < X < 64)
qnorm(0.975)                             # le quantile : 1,96
qt(0.975, df = 29)                       # Student à 29 ddl : 2,045
rnorm(30, mean = 60, sd = 2)             # 30 tirages au hasard
pbinom(6, 10, 0.5, lower.tail = FALSE)   # P(au moins 7 piles sur 10)
sample(commandes$montant_eur, 30)        # 30 commandes tirées au hasard
replicate(1000, mean(sample(commandes$montant_eur, 30)))  # 1000 moyennes de 30
```

Préfixes : `p` = probabilité cumulée, `q` = quantile, `r` = tirage aléatoire, `d` = densité. Lois : `norm`, `t`, `binom`, `chisq`, `lnorm`, `unif`.

## 8. Les tests : une ligne chacun

| Question | Commande |
|---|---|
| Cette moyenne vaut-elle 50 ? | `t.test(commandes$montant_eur, mu = 50)` |
| Deux groupes ont-ils la même moyenne ? | `t.test(delai_livraison_jours ~ transporteur, data = chrono_colissimo)` |
| Avant / après sur les mêmes individus ? | `t.test(avant, apres, paired = TRUE)` |
| Plus de deux groupes ? | `modele = aov(montant_eur ~ canal, data = commandes)` puis `summary(modele)` et `TukeyHSD(modele)` |
| Deux pourcentages (A/B test) ? | `prop.test(table(visites$version_page, visites$achat))` |
| Deux variables qualitatives liées ? | `chisq.test(table(commandes$transporteur, commandes$satisfait))` |
| Ces effectifs suivent-ils la loi attendue ? | `chisq.test(c(11, 20, 15), p = c(1/3, 1/3, 1/3))` |
| Combien de visites pour voir 3 % contre 4 % ? | `power.prop.test(p1 = 0.03, p2 = 0.04, power = 0.8)` |
| Combien de clients pour ± 5 € ? | `power.t.test(delta = 5, sd = 31, power = 0.8)` |
| Cette variable est-elle normale ? | `qqnorm(x); qqline(x)` et `shapiro.test(x)` (regarder le graphique d'abord) |

Le test de Student à deux groupes attend un facteur à **deux** modalités : filtrer d'abord, par exemple `chrono_colissimo = commandes[commandes$transporteur != "Mondial Relay", ]`.

### Lire la sortie d'un test

```
t = 3.31, df = 37.7, p-value = 0.002
95 percent confidence interval:
 0.19 0.81
sample estimates:
mean in group medicament  mean in group placebo
                   38.40                  38.90
```

- `p-value` : si rien ne se passait, un écart au moins aussi grand arriverait 2 fois sur 1 000. En dessous de 0,05, on rejette H0.
- `confidence interval` : l'effet est quelque part entre 0,19 et 0,81 °C. C'est lui qu'on met dans le rapport, avec l'effectif.
- Récupérer une valeur : `res = t.test(...)` puis `res$p.value`, `res$conf.int`, `res$estimate`.

## 9. Modéliser et prévoir

```r
modele = lm(chiffre_affaires_eur ~ budget_pub_eur, data = ca)
summary(modele)          # coefficients, erreurs standard, p-values, R²
confint(modele)          # IC à 95 % des coefficients
residuals(modele)        # les résidus ; hist(residuals(modele))
par(mfrow = c(2, 2)); plot(modele)    # les 4 graphiques de diagnostic

nouveau = data.frame(budget_pub_eur = 6000)
predict(modele, nouveau, interval = "confidence")    # le CA moyen à 6 000 €
predict(modele, nouveau, interval = "prediction")    # le CA d'une semaine à 6 000 €
```

`aov(montant ~ canal)` et `lm(montant ~ canal)` sont le même calcul : Student et l'ANOVA sont des régressions.

## 10. Sauver, exporter

```r
write.table(resultat, "resultat.csv", sep = ";", dec = ",", row.names = FALSE)
png("graphique.png"); hist(x); dev.off()     # enregistrer un graphique
save.image("session.RData")                  # tout l'espace de travail ; load("session.RData") pour le recharger
```

## 11. Les erreurs qu'on fait tous

- `Error: object 'commandes' not found` : la ligne de chargement n'a pas été exécutée, ou faute de frappe (R distingue majuscules et minuscules).
- `could not find function "t.test"` : une faute de frappe dans le nom ; ou un package non chargé (`library(nom)`).
- Un `+` au lieu de `>` dans la console : une parenthèse ou un guillemet n'est pas fermé ; touche Échap.
- `NA` partout dans `summary` : le fichier a été lu avec le mauvais `dec` ou `sep` ; refaire `str()` pour vérifier que les nombres sont bien `num`, pas `chr`.
- Un facteur lu comme texte : `commandes$canal = as.factor(commandes$canal)`.

## 12. Installer un package (une seule fois)

```r
install.packages("agricolae")   # télécharge et installe
library(agricolae)              # à refaire à chaque session
HSD.test(modele, "canal", console = TRUE)   # lettres a, b, c des groupes
```
