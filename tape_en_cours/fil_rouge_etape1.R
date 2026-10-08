# Fil rouge, étape 1 : décrire

# read.csv2 = CSV « français » (séparateur ; décimale ,) ; le fichier commence par un BOM
commandes <- read.csv2("medias/filRouge/commandes.csv", fileEncoding = "UTF-8-BOM")
str(commandes)
summary(commandes)

montant <- commandes$montant_eur

# Position et dispersion
mean(montant)        # 49.12
median(montant)      # 40.94
sd(montant)          # 31.01
quantile(montant)    # 5.83  28.50  40.94  60.40  271.33
quantile(montant, c(0.9, 0.99))
IQR(montant)         # 31.90
table(round(montant / 10) * 10)   # mode arrondi à 10 € : 30

# Classes, effectifs, fréquences, fréquences cumulées
bornes <- c(0, 25, 50, 75, 100, 150, 200, 300)
effectifs <- table(cut(montant, bornes, right = FALSE))
effectifs                           # 342 947 400 174 111 17 9
prop.table(effectifs)
cumsum(prop.table(effectifs))

hist(montant, breaks = bornes)
boxplot(montant, horizontal = TRUE)

# Par canal et par transporteur
table(commandes$canal)
table(commandes$transporteur)
tapply(commandes$delai_livraison_jours, commandes$transporteur, summary)
tapply(commandes$delai_livraison_jours, commandes$transporteur, sd)   # 0.65  1.27  1.58
boxplot(montant_eur ~ canal, data = commandes)
boxplot(delai_livraison_jours ~ transporteur, data = commandes)

# Q1 : moyenne 49 €, médiane 41 €. L'histogramme est asymétrique à droite : quelques gros paniers
# tirent la moyenne. La médiane décrit le client typique ; la moyenne sert au CA. Donner les deux.

# Q2 : part du CA faite par les 10 % de commandes les plus grosses
grosses <- montant[montant >= quantile(montant, 0.9)]
sum(grosses) / sum(montant)         # 0.243

# Q3 : les boîtes des délais ne se chevauchent presque pas (1,7 j contre 3,2 et 4,0) ;
# avec 400 à 1000 commandes par transporteur, le test de demain ne fera que confirmer.

# Q4 : la satisfaction moyenne (3,5) cache la répartition
table(commandes$satisfaction)       # 18  210  709  806  257
barplot(table(commandes$satisfaction))
mean(commandes$satisfaction <= 2)   # 11 % de mécontents, invisibles dans la moyenne
