# Entreprises A et B : comparer deux distributions de salaires (TP 4.1, question 2)

salaires <- read.csv("medias/descriptives/salaires/entrepriseAB.csv")
head(salaires)
summary(salaires)            # A : médiane 2878, moyenne 2859 ; B : médiane 2689, moyenne 2975
sapply(salaires, sd)         # 847 contre 1463 : B est deux fois plus dispersée

# Histogrammes superposés, mêmes classes pour les deux
bornes <- seq(1000, 7000, by = 500)
hist(salaires$entreprise_a, breaks = bornes, col = rgb(0, 0, 1, 0.4), xlab = "salaire (€)", main = "A (bleu) et B (rouge)")
hist(salaires$entreprise_b, breaks = bornes, col = rgb(1, 0, 0, 0.4), add = TRUE)

# Densités
plot(density(salaires$entreprise_a), col = "blue", lwd = 2, xlim = c(500, 7500), main = "Densités")
lines(density(salaires$entreprise_b), col = "red", lwd = 2)
legend("topright", c("A", "B"), col = c("blue", "red"), lwd = 2)

# Fréquences cumulées : la médiane se lit à 0,5
plot(ecdf(salaires$entreprise_a), col = "blue", main = "Fréquences cumulées")
plot(ecdf(salaires$entreprise_b), col = "red", add = TRUE)
abline(h = 0.5, lty = 2)

# Boxplots côte à côte
boxplot(salaires, col = c("lightblue", "pink"), ylab = "salaire (€)")

# Même médiane à peu près, pas la même dispersion : plus de bas ET de hauts salaires chez B.
t.test(salaires$entreprise_a, salaires$entreprise_b)    # p ≈ 0,6 : moyennes non distinguables (jour 2)
var.test(salaires$entreprise_a, salaires$entreprise_b)  # les variances, elles, diffèrent
