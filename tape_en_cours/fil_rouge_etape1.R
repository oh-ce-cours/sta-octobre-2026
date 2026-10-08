# Fil rouge, étape 1 : décrire (version R de ce qu'on a fait dans Excel)
# Les valeurs attendues sont en commentaire après chaque commande.

# 0. Charger les commandes --------------------------------------------------
commandes = read.table("medias/filRouge/commandes.csv",
                       sep = ";", dec = ",", header = TRUE,
                       fileEncoding = "UTF-8-BOM")
str(commandes)       # 2000 lignes, 10 colonnes ; montant_eur doit être num, pas chr
head(commandes)

# 1. Le panier : position, dispersion --------------------------------------
panier = commandes$montant_eur

mean(panier)         # 49.12  : la moyenne
median(panier)       # 40.94  : la médiane
sd(panier)           # 31.01  : l'écart-type (divise par n-1, comme ECARTYPE.STANDARD)
quantile(panier)     # min 5.83, Q1 28.50, médiane 40.94, Q3 60.40, max 271.33
IQR(panier)          # 31.90  : écart inter-quartiles
quantile(panier, c(0.90, 0.99))   # 87.71 et 168.21

# le mode, arrondi à 10 € : la valeur la plus fréquente
table(round(panier / 10) * 10)    # 30 € (437 commandes), puis 40 € (353)
summary(panier)                   # tout d'un coup

# 2. Découper en classes : effectifs, fréquences, fréquences cumulées ------
bornes = c(0, 25, 50, 75, 100, 150, 200, 300)
classes = cut(panier, bornes, right = FALSE)    # [0,25) [25,50) ... [200,300)
effectifs = table(classes)
effectifs                         # 342  947  400  174  111  17  9
prop.table(effectifs)             # fréquences : 0.171 0.473 0.200 0.087 0.056 0.009 0.004
cumsum(prop.table(effectifs))     # cumulées : 0.171 0.644 0.845 0.931 0.987 0.996 1

# 3. L'histogramme ---------------------------------------------------------
hist(panier, breaks = bornes, main = "Montant des commandes", xlab = "€")
# ou avec des classes automatiques :
hist(panier, breaks = 30)
boxplot(panier, horizontal = TRUE)

# 4. Effectifs et fréquences par canal et par transporteur -----------------
table(commandes$canal)
#   Direct  Email  Réseaux sociaux  SEA  SEO
#      314    381              252  419  634
round(prop.table(table(commandes$canal)), 3)
table(commandes$transporteur)
#   Chronopost  Colissimo  Mondial Relay
#          396       1002            602

# 5. Délai de livraison par transporteur -----------------------------------
tapply(commandes$delai_livraison_jours, commandes$transporteur, mean)
#   Chronopost 1.70   Colissimo 3.21   Mondial Relay 3.97
tapply(commandes$delai_livraison_jours, commandes$transporteur, median)
#   2  3  4
tapply(commandes$delai_livraison_jours, commandes$transporteur, sd)
#   0.65  1.27  1.58

# la même chose en un tableau :
aggregate(delai_livraison_jours ~ transporteur, data = commandes,
          FUN = function(x) c(n = length(x), moyenne = mean(x), mediane = median(x), sd = sd(x)))

# 6. Boxplot du montant par canal ------------------------------------------
boxplot(montant_eur ~ canal, data = commandes, ylab = "€")
tapply(commandes$montant_eur, commandes$canal, mean)
#   Direct 47.32   Email 55.44   Réseaux sociaux 44.58   SEA 49.07   SEO 48.05
tapply(commandes$montant_eur, commandes$canal, median)
#   39.30   45.66   37.42   40.76   40.52

# Les questions ------------------------------------------------------------

# Q1. Moyenne (49 €) et médiane (41 €) différentes : pourquoi ?
hist(panier, breaks = 30)         # asymétrique à droite : quelques très gros paniers
mean(panier) > median(panier)     # TRUE : la queue à droite tire la moyenne
# coefficient d'asymétrie, à la main (pas de fonction de base dans R) :
mean(((panier - mean(panier)) / sd(panier))^3)   # ≈ 2.1, très asymétrique (0 = symétrique)
# -> la médiane décrit le client typique ; la moyenne sert au CA (CA = moyenne × nombre).
#    Donner les deux à la direction, et dire lequel sert à quoi.

# Q2. Quelle part du CA font les 10 % de commandes les plus grosses ?
seuil = quantile(panier, 0.90)                    # 87.71 €
grosses = panier[panier >= seuil]
length(grosses)                                   # 200 commandes
sum(grosses) / sum(panier)                        # 0.243 : 24,3 % du chiffre d'affaires
# variante : trier et prendre les 200 dernières
sum(sort(panier, decreasing = TRUE)[1:200]) / sum(panier)

# Q3. Que dire des délais sans aucun test ?
boxplot(delai_livraison_jours ~ transporteur, data = commandes)
# Les boîtes ne se chevauchent presque pas : Chronopost 1,7 j contre 3,2 et 4,0.
# Avec 400 à 1000 commandes par transporteur, il n'y a guère de doute ;
# le test (étape 4) confirmera et donnera la précision de l'écart.

# Q4. La satisfaction moyenne est de 3,5 sur 5 : bon résumé ?
mean(commandes$satisfaction)                      # 3.54
table(commandes$satisfaction)                     # 1: 18   2: 210   3: 709   4: 806   5: 257
round(prop.table(table(commandes$satisfaction)), 2)   # 0.01 0.10 0.35 0.40 0.13
barplot(table(commandes$satisfaction), xlab = "note", ylab = "commandes")
# Non : variable ordinale à 5 modalités. Le diagramme en bâtons est plus honnête :
# 11 % de clients mécontents (notes 1 et 2), ce que la moyenne cache.
mean(commandes$satisfaction <= 2)                 # 0.114
