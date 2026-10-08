# Fil rouge, étape 2 : échantillonner

commandes <- read.csv2("medias/filRouge/commandes.csv", fileEncoding = "UTF-8-BOM")
montant <- commandes$montant_eur

mu    <- mean(montant)   # 49.12 : la vraie valeur, qu'on ne connaît jamais en pratique
sigma <- sd(montant)     # 31.01

# 1. Mon tirage de 30 commandes
n <- 30
echantillon <- commandes[sample(nrow(commandes), n), ]
x <- echantillon$montant_eur

mean(x)                  # mon panier moyen, à noter dans le tableau partagé
sd(x)                    # mon écart-type
mean(echantillon$satisfaction)

# 2. Mon intervalle de confiance à 95 %
t_critique <- qt(0.975, df = n - 1)          # 2.045 (Excel : LOI.STUDENT.INVERSE.BILATERALE(0,05;29))
mean(x) + c(-1, 1) * t_critique * sd(x) / sqrt(n)
t.test(x)$conf.int                           # pareil, en une ligne
# contient-il 49.12 ?

# 3. Le tableau de la salle (coller les valeurs de chacun)
moyennes_salle <- c(56.7, 44.2, 51.9, 47.3, 60.1, 42.8, 49.5, 53.0)
sd_salle       <- c(43.7, 25.1, 33.8, 28.9, 39.2, 24.4, 30.6, 35.5)

mean(moyennes_salle)     # proche de 49.12
sd(moyennes_salle)       # à comparer à sigma / sqrt(30) = 5.66, l'erreur standard
bas  <- moyennes_salle - t_critique * sd_salle / sqrt(n)
haut <- moyennes_salle + t_critique * sd_salle / sqrt(n)
sum(bas <= mu & mu <= haut)                  # intervalles qui contiennent la vraie valeur : 7 ou 8 sur 8

# 4. Ce que la salle fait 8 fois, une boucle le fait 1000 fois
moyennes <- numeric(1000)
contient <- logical(1000)
for (i in 1:1000) {
  x <- sample(montant, n)
  moyennes[i] <- mean(x)
  bas  <- mean(x) - t_critique * sd(x) / sqrt(n)
  haut <- mean(x) + t_critique * sd(x) / sqrt(n)
  contient[i] <- bas <= mu & mu <= haut
}
mean(moyennes)           # 49.1 : pas de biais
sd(moyennes)             # 5.6  : sigma / sqrt(30)
mean(contient)           # 0.93 : un peu moins que 95 %, le panier est très asymétrique et n petit
hist(moyennes, breaks = 30); abline(v = mu, col = "red", lwd = 2)   # en cloche : TCL

# Relancer avec n <- 100 : sd(moyennes) tombe à 3.1 (erreur divisée par 2 pour 4 fois plus de clients),
# mean(contient) remonte à 0.95.

# 5. Combien de clients rappeler ?  e = 1.96 * sigma / sqrt(n)  =>  n = (1.96 * sigma / e)^2
ceiling((1.96 * sigma / 5)^2)   # 148 pour ± 5 €
ceiling((1.96 * sigma / 2)^2)   # 924 pour ± 2 €
