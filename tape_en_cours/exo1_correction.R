# --- Préparation des données d'exemple (à adapter avec vos données) ---> 
library(readr)
setwd('Desktop/sta-octobre-2026/medias/filRouge/')

commandes <- read_delim("commandes.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
montant <- commandes$montant_eur
les_quartiles <- quantile(montant, probs = c(0, 0.25, 0.5, 0.75, 1))> 
print(les_quartiles)
la_moyenne <- mean(montant)
l_ecart_type <- sd(montant)
montant_arrondi <- round(montant / 10) * 10
tri_frequence <- table(montant_arrondi)
le_mode <- as.numeric(names(tri_frequence)[which.max(tri_frequence)])
cat("--- STATISTIQUES DESCRIPTIVES ---\n",     "Minimum :", min(montant), "€\n",     "Premier Quartile (Q1) :", quantile(montant, 0.25), "€\n",     "Médiane :", median(montant), "€\n",     "Troisième Quartile (Q3) :", quantile(montant, 0.75), "€\n",     "Maximum :", max(montant), "€\n",     "Moyenne :", round(la_moyenne, 2), "€\n",     "Écart-type :", round(l_ecart_type, 2), "€\n",     "Mode (arrondi à 10€) :", le_mode, "€\n")
