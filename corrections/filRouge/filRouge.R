# Fil rouge « boutique en ligne » : commandes R de correction.
# Les chiffres des corrections viennent de analyse.py ; R donne les mêmes aux arrondis près.

commandes <- read.csv2("../medias/commandes.csv", fileEncoding = "UTF-8-BOM")
visites   <- read.csv2("../medias/visitesAB.csv",  fileEncoding = "UTF-8-BOM")
ca        <- read.csv2("../medias/caHebdo.csv",    fileEncoding = "UTF-8-BOM")

## Étape 1 : décrire ---------------------------------------------------------
montant <- commandes$montant_eur
summary(montant); sd(montant)
quantile(montant, c(0.9, 0.99))
bornes <- c(0, 25, 50, 75, 100, 150, 200, 300)
table(cut(montant, bornes, right = FALSE))
hist(montant, breaks = bornes)
table(commandes$canal); table(commandes$transporteur)
tapply(commandes$delai_livraison_jours, commandes$transporteur, summary)
boxplot(montant_eur ~ canal, data = commandes)
barplot(table(commandes$satisfaction))
sum(montant[montant >= quantile(montant, 0.9)]) / sum(montant)   # 0.243

## Étape 2 : échantillonner --------------------------------------------------
mu <- mean(montant); sigma <- sd(montant)
n <- 30
t_critique <- qt(0.975, n - 1)                       # 2.045
moyennes <- numeric(1000); contient <- logical(1000)
for (i in 1:1000) {
  x <- sample(montant, n)
  moyennes[i] <- mean(x)
  demi <- t_critique * sd(x) / sqrt(n)
  contient[i] <- mean(x) - demi <= mu & mu <= mean(x) + demi
}
sd(moyennes); sigma / sqrt(n)                        # 5.6 et 5.66
mean(contient)                                       # 0.93
hist(moyennes)                                       # en cloche : TCL
t.test(montant[1:30])                                # IC des 30 premières commandes
ceiling((1.96 * sigma / 5)^2)                        # 148 clients pour ± 5 €

## Étape 3 : modéliser et prévoir -------------------------------------------
modele <- lm(chiffre_affaires_eur ~ budget_pub_eur, data = ca)
plot(chiffre_affaires_eur ~ budget_pub_eur, data = ca); abline(modele, col = "red")
summary(modele)                                      # pente 4.49, R² 0.886, sres 2410
confint(modele)
nouveau <- data.frame(budget_pub_eur = 6000)
predict(modele, nouveau, interval = "confidence")    # CA moyen
predict(modele, nouveau, interval = "prediction")    # une semaine
par(mfrow = c(2, 2)); plot(modele); par(mfrow = c(1, 1))

## Étape 4 : tester ----------------------------------------------------------
# A/B
tab <- table(visites$version_page, visites$achat)
prop.table(tab, 1)
chisq.test(tab)                                      # p = 0.073
prop.test(tab[, c("oui", "non")])                    # même test, avec l'IC de la différence
power.prop.test(p1 = 0.03, p2 = 0.04, power = 0.8)   # 5300 par version

# Chronopost
deux <- subset(commandes, transporteur != "Mondial Relay")
t.test(delai_livraison_jours ~ transporteur, data = deux)   # 1.52 j, IC [1.41 ; 1.62]
commandes$satisfait <- commandes$satisfaction >= 4
tab_sat <- table(commandes$transporteur, commandes$satisfait)
prop.table(tab_sat, 1)
chisq.test(tab_sat)$expected
chisq.test(tab_sat)                                  # p < 1e-20

# Emailing
modele_canal <- aov(montant_eur ~ canal, data = commandes)
summary(modele_canal)                                # F = 5.81, p = 0.0001
TukeyHSD(modele_canal)
kruskal.test(montant_eur ~ canal, data = commandes)  # même conclusion sans hypothèse de normalité
t.test(montant, mu = 50)                             # objectif 50 € : p = 0.20

## Étape 5 : adéquation ------------------------------------------------------
observe <- table(cut(montant, bornes, right = FALSE))
attendu_norm  <- diff(pnorm(bornes, mean(montant), sd(montant))) * 2000
attendu_lnorm <- diff(plnorm(bornes, mean(log(montant)), sd(log(montant)))) * 2000
cbind(observe, round(attendu_norm), round(attendu_lnorm))
chisq.test(observe, p = attendu_lnorm / sum(attendu_lnorm))
hist(montant, breaks = bornes, freq = FALSE)
curve(dnorm(x, mean(montant), sd(montant)), add = TRUE, col = "red")
curve(dlnorm(x, mean(log(montant)), sd(log(montant))), add = TRUE, col = "blue")
shapiro.test(residuals(modele))                      # p = 0.74
