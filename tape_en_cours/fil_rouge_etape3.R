# Fil rouge, étape 3 : modéliser et prévoir

ca <- read.csv2("medias/filRouge/caHebdo.csv", fileEncoding = "UTF-8-BOM")
head(ca)

# le nuage et la droite
plot(chiffre_affaires_eur ~ budget_pub_eur, data = ca, xlab = "budget pub (€)", ylab = "CA (€)")
modele <- lm(chiffre_affaires_eur ~ budget_pub_eur, data = ca)
abline(modele, col = "red", lwd = 2)

# lire le modèle
summary(modele)        # (Intercept) 17165, pente 4.49 (erreur standard 0.23, p < 2e-16), R² 0.886, sres 2410
confint(modele)        # pente entre 4.03 et 4.95 à 95 %
cor(ca$budget_pub_eur, ca$chiffre_affaires_eur)   # r = 0.94, et r² = R²

# les résidus : on veut ne rien voir
res <- residuals(modele)
plot(ca$budget_pub_eur, res); abline(h = 0, lty = 2)   # pas de courbure, pas d'éventail
hist(res)
shapiro.test(res)      # p = 0.74 : compatible avec une loi normale
sd(res)                # ≈ 2410 : l'erreur typique sur une semaine
par(mfrow = c(2, 2)); plot(modele); par(mfrow = c(1, 1))   # les 4 graphiques de diagnostic

# prévoir à 6 000 €
nouveau <- data.frame(budget_pub_eur = c(3000, 6000))
predict(modele, nouveau)                              # 30 631 et 44 097
predict(modele, nouveau, interval = "confidence")     # CA moyen des semaines à ce budget : [42 935 ; 45 258]
predict(modele, nouveau, interval = "prediction")     # le CA d'UNE semaine : [39 119 ; 49 075]

# Q1 : +4,49 € de CA par euro de pub (4,03 à 4,95) ; 17 165 € à budget nul, hors plage observée.
#      Association sur 52 semaines, pas une preuve de cause (la saison peut tirer les deux).
# Q2 : 89 % de la variabilité du CA suit le budget ; le reste (sres 2 410 €) vient d'ailleurs.
# Q3 : résidus sans structure : le modèle linéaire tient.
# Q4 : 44 100 € en moyenne ; une semaine donnée entre 39 100 et 49 100 €.
# Q5 : 12 000 € est hors de la plage ajustée (1 570 à 6 480 €) : on refuse d'extrapoler.
range(ca$budget_pub_eur)
# Q6 : « confidence » = où est la droite (se resserre avec n) ; « prediction » = où tombera la semaine
#      (ne descend jamais sous ± 2 sres).
