# Entreprises A et B : comparer deux distributions de salaires sur le même graphique
# (TP 4.1 « effectifs cumulés », question 2 : peut-on comparer à une autre entreprise ?)

# 0. Charger -----------------------------------------------------------------
# Un fichier par entreprise, une colonne, format anglais (point décimal) : read.csv suffit.
A = read.csv("medias/descriptives/salaires/entrepriseA.csv")$entreprise_a
B = read.csv("medias/descriptives/salaires/entrepriseB.csv")$entreprise_b
# (ou les deux d'un coup : ab = read.csv("medias/descriptives/salaires/entrepriseAB.csv"))

summary(A)   # 50 salaires, de 1 430 à 4 093 €, médiane 2 878, moyenne 2 859
summary(B)   # 50 salaires, de 1 125 à 6 598 €, médiane 2 689, moyenne 2 975
sd(A); sd(B) # 847 contre 1 463 : B est deux fois plus dispersée

# 1. En R de base : deux histogrammes superposés, en transparence ----------
bornes = seq(1000, 7000, by = 500)        # les mêmes classes pour les deux, sinon on compare des choux et des carottes
hist(A, breaks = bornes, col = rgb(0.2, 0.4, 0.8, 0.5), xlim = c(1000, 7000),
     main = "Salaires : entreprise A (bleu) et B (rouge)", xlab = "salaire mensuel (€)", ylab = "salariés")
hist(B, breaks = bornes, col = rgb(0.9, 0.3, 0.2, 0.5), add = TRUE)
legend("topright", legend = c("A", "B"), fill = c(rgb(0.2, 0.4, 0.8, 0.5), rgb(0.9, 0.3, 0.2, 0.5)))

# 2. En R de base : deux courbes de densité ----------------------------------
dA = density(A); dB = density(B)
plot(dA, col = "steelblue", lwd = 3, xlim = c(500, 7500), ylim = c(0, max(dA$y, dB$y)),
     main = "La même information, lissée", xlab = "salaire mensuel (€)")
lines(dB, col = "firebrick", lwd = 3)
abline(v = c(median(A), median(B)), col = c("steelblue", "firebrick"), lty = 2)
legend("topright", legend = c("A", "B"), col = c("steelblue", "firebrick"), lwd = 3)

# 3. Les fréquences cumulées, où la médiane se lit à 0,5 --------------------
plot(ecdf(A), col = "steelblue", main = "Fréquences cumulées croissantes", xlab = "salaire (€)", ylab = "part des salariés en dessous")
plot(ecdf(B), col = "firebrick", add = TRUE)
abline(h = 0.5, lty = 3)
# Lecture : la courbe de B est à gauche de A sous 2 500 € (plus de bas salaires)
# et à droite au-dessus de 3 500 € (plus de hauts salaires). Même médiane à peu près, pas la même dispersion.

# 4. Avec ggplot2 : on met les deux entreprises dans un seul tableau « long »
library(ggplot2)
salaires = data.frame(entreprise = rep(c("A", "B"), c(length(A), length(B))),
                      salaire = c(A, B))
head(salaires)

# histogrammes superposés
ggplot(salaires, aes(x = salaire, fill = entreprise)) +
  geom_histogram(breaks = bornes, position = "identity", alpha = 0.5, colour = "white") +
  scale_fill_manual(values = c(A = "steelblue", B = "firebrick")) +
  labs(title = "Même médiane, pas la même dispersion",
       subtitle = "50 salariés par entreprise, classes de 500 €",
       x = "salaire mensuel (€)", y = "salariés") +
  theme_minimal(base_size = 13)

# densités superposées, avec les médianes
medianes = aggregate(salaire ~ entreprise, data = salaires, FUN = median)
ggplot(salaires, aes(x = salaire, fill = entreprise, colour = entreprise)) +
  geom_density(alpha = 0.35, linewidth = 1) +
  geom_vline(data = medianes, aes(xintercept = salaire, colour = entreprise), linetype = "dashed") +
  scale_fill_manual(values = c(A = "steelblue", B = "firebrick")) +
  scale_colour_manual(values = c(A = "steelblue", B = "firebrick")) +
  labs(title = "Entreprise B : plus de bas salaires et plus de hauts salaires",
       subtitle = "densité lissée ; pointillés : médianes (2 878 € et 2 689 €)",
       x = "salaire mensuel (€)", y = NULL) +
  theme_minimal(base_size = 13)

# ou, pour ne rien superposer : un panneau par entreprise, même axe
ggplot(salaires, aes(x = salaire, fill = entreprise)) +
  geom_histogram(breaks = bornes, colour = "white", show.legend = FALSE) +
  facet_wrap(~ entreprise, ncol = 1) +
  scale_fill_manual(values = c(A = "steelblue", B = "firebrick")) +
  theme_minimal(base_size = 13)

# et les boîtes à moustaches côte à côte, le résumé le plus compact
ggplot(salaires, aes(x = entreprise, y = salaire, fill = entreprise)) +
  geom_boxplot(show.legend = FALSE, width = 0.5) +
  geom_jitter(width = 0.1, alpha = 0.4) +
  scale_fill_manual(values = c(A = "steelblue", B = "firebrick")) +
  theme_minimal(base_size = 13)

# 5. Et si on veut un chiffre : les deux moyennes sont-elles différentes ? (jour 2)
t.test(A, B)     # p ≈ 0,6 : rien ne permet de dire que les moyennes diffèrent ;
                 # ce qui diffère, c'est la dispersion : var.test(A, B)
