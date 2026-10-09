# on lit le fichier CSV, on dit que la première ligne contient les
# noms des données et que le séparateur est une virgule et que les
# nombres flottants ont des "," comme séparateur
df = read.table("../media/etude_de_cas.csv", header=TRUE, sep=",", dec=",")

# on peut demander la description du tableau de données
summary(df)
#       bwt          gestation       parity             age
#  Min.   :1.570   Min.   :181.0   Mode :logical   Min.   :15.00
#  1st Qu.:3.090   1st Qu.:272.0   FALSE:865       1st Qu.:23.00
#  Median :3.430   Median :280.0   TRUE :308       Median :26.00
#  Mean   :3.413   Mean   :279.2                   Mean   :27.23
#  3rd Qu.:3.740   3rd Qu.:288.0                   3rd Qu.:31.00
#  Max.   :5.030   Max.   :353.0                   Max.   :45.00
#      height          weight         smoke            tension
#  Min.   :132.5   Min.   : 39.41   Mode :logical   Min.   : 9.20
#  1st Qu.:155.0   1st Qu.: 51.64   FALSE:714       1st Qu.:12.50
#  Median :160.0   Median : 56.62   TRUE :459       Median :13.70
#  Mean   :160.1   Mean   : 58.20                   Mean   :14.36
#  3rd Qu.:165.0   3rd Qu.: 62.97                   3rd Qu.:16.10
#  Max.   :180.0   Max.   :113.25                   Max.   :23.70

# histogramme de l'age des mères
hist(df$age, main="Diagramme en bâton des ages des mères", xlab="Age", ylab="NNombre de mère dans la classe")


## on regarde puis on ferme la fenetre qui s'est ouverte


# boxplot du poids des bébés
boxplot(df$bwt, main="Boxplot du poids des bébés", ylab="Poids (kg)")


## on regarde puis on ferme la fenetre qui s'est ouverte


## comparaison des poids des bébés selon que la mère fume ou pas
boxplot(bwt~smoke, data=df, main="Comparaison des poids des bébés selon que la mère fume ou pas", xlab="Mère fumeuse ?", ylab="Poids (kg)")


## on regarde puis on ferme la fenetre qui s'est ouverte


# scatter plot poids des bébés en fonction du temps de gestation
## on utilise une couleur avec transparence pour mieux visualiser les "applats" de points au même endroit
plot(df$gestation, df$bwt, main="Poids des bébés en fonction de la durée de gestation", col=rgb(0.1, 0.5, 0.9, 0.25))
## on rajoute la droite de régression
reg = lm(df$bwt~df$gestation) # on effectue le calcul de la régression
abline(reg, col="red") # on rajoute la droite de régression (abline permet de tracer une droite en lui donnant les paramètres de pente et ordonnée à l'origine)



# comparaison des poids en fonnction de la durée de gestation selon que la mère fume ou pas
# extraction des deux sous dataframes
df_smoke = df[df$smoke == TRUE, ] # on sélectionne les lignes où smoke est à TRUE
df_non_smoke = df[df$smoke != TRUE, ] # on sélectionne les lignes où smoke n'est pas à TRUE

plot(df_smoke$gestation, df_smoke$bwt, main="Poids des bébés en fonction de la durée de gestation", col=rgb(0.0, 0.0, 0.9, 0.25))
reg = lm(df_smoke$bwt~df_smoke$gestation) # on effectue le calcul de la régression
abline(reg, col="blue") # on rajoute la droite de régression (abline permet de tracer une droite en lui donnant les paramètres de pente et ordonnée à l'origine)

points(df_non_smoke$gestation, df_non_smoke$bwt, col=rgb(0.9, 0.0, 0.0, 0.25))
reg = lm(df_non_smoke$bwt~df_non_smoke$gestation) # on effectue le calcul de la régression
abline(reg, col="red") # on rajoute la droite de régression (abline permet de tracer une droite en lui donnant les paramètres de pente et ordonnée à l'origine)


# le fait de fumer a-t-il un impact sur le poids des bébés ?
t.test(df_smoke$bwt, df_non_smoke$bwt)

# 	Welch Two Sample t-test

# data:  df_smoke$bwt and df_non_smoke$bwt
# t = -8.6333, df = 942.6, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#  -0.3252901 -0.2047939
# sample estimates:
# mean of x mean of y
#  3.251961  3.517003
## oui