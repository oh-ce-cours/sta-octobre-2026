# ggplot2 sur le fil rouge : du graphique en une ligne au graphique qu'on met dans le rapport
#
# L'idée de ggplot : un graphique = des données + des "esthétiques" (quelle colonne sur x,
# sur y, en couleur) + des couches (geom_...) qu'on empile avec +.
# On construit chaque graphique en ajoutant une ligne à la fois : c'est ça, la démonstration.

# install.packages("ggplot2")   # une seule fois
library(ggplot2)
library(scales)                 # installé avec ggplot2 : formats des axes (€, %)

# 0. Les données ------------------------------------------------------------
commandes = read.table("medias/filRouge/commandes.csv", sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")
visites   = read.table("medias/filRouge/visitesAB.csv",  sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")
ca        = read.table("medias/filRouge/caHebdo.csv",    sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")

commandes$date = as.Date(commandes$date, format = "%d/%m/%Y")
commandes$mois = format(commandes$date, "%Y-%m")
ca$numero_semaine = 1:nrow(ca)

euros = label_number(suffix = " €", big.mark = " ")   # pour les axes

# 1. Le panier : de hist() à un graphique de rapport ------------------------
# une ligne :
ggplot(commandes, aes(x = montant_eur)) + geom_histogram()

# on affine, une couche à la fois (relancer après chaque ajout) :
ggplot(commandes, aes(x = montant_eur)) +
  geom_histogram(binwidth = 5, fill = "steelblue", colour = "white") +
  geom_vline(xintercept = median(commandes$montant_eur), linetype = "dashed") +
  geom_vline(xintercept = mean(commandes$montant_eur), colour = "firebrick") +
  annotate("text", x = 41, y = 190, label = "médiane 41 €", hjust = 1.1) +
  annotate("text", x = 49, y = 170, label = "moyenne 49 €", hjust = -0.1, colour = "firebrick") +
  scale_x_continuous(labels = euros) +
  labs(title = "Le panier n'est pas symétrique",
       subtitle = "2 000 commandes de 2025 : quelques gros paniers tirent la moyenne vers le haut",
       x = NULL, y = "commandes", caption = "Maison Verdier, commandes.csv") +
  theme_minimal(base_size = 13)

# 2. Un graphique par groupe sans rien recalculer : le boxplot par canal -----
ggplot(commandes, aes(x = reorder(canal, montant_eur, median), y = montant_eur, fill = canal)) +
  geom_boxplot(outlier.alpha = 0.3, show.legend = FALSE) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, colour = "firebrick") +
  scale_y_continuous(labels = euros) +
  coord_flip() +
  labs(title = "Les clients venus par emailing dépensent plus",
       subtitle = "boîtes : médiane et quartiles ; losange rouge : moyenne",
       x = NULL, y = "panier") +
  theme_minimal(base_size = 13)

# 3. Les facettes : la même question posée pour chaque sous-groupe ---------
# Délai de livraison par transporteur, un panneau par transporteur
ggplot(commandes, aes(x = delai_livraison_jours, fill = transporteur)) +
  geom_bar(show.legend = FALSE) +
  facet_wrap(~ transporteur, ncol = 1) +
  labs(title = "Chronopost livre en 1 à 2 jours, Mondial Relay en 3 à 6",
       x = "délai (jours)", y = "commandes") +
  theme_minimal(base_size = 13)

# Satisfaction par transporteur : des barres en proportions
ggplot(commandes, aes(x = transporteur, fill = factor(satisfaction, levels = 5:1))) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = label_percent()) +
  scale_fill_brewer(palette = "RdYlGn", direction = -1, name = "note") +
  labs(title = "La satisfaction suit la vitesse de livraison",
       subtitle = "part de chaque note (1 à 5) par transporteur",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 13)

# 4. Le A/B test, en un coup d'œil, par appareil ----------------------------
ggplot(visites, aes(x = version_page, fill = achat)) +
  geom_bar(position = "fill") +
  facet_wrap(~ appareil) +
  scale_y_continuous(labels = label_percent()) +
  scale_fill_manual(values = c(non = "grey85", oui = "darkorange")) +
  coord_cartesian(ylim = c(0, 0.08)) +       # on zoome sur les 8 premiers % : la conversion est petite
  labs(title = "B convertit un peu mieux... sur tous les appareils ?",
       subtitle = "taux d'achat par version de page, 4 000 visites (axe tronqué à 8 %)",
       x = "version de la page", y = "visites") +
  theme_minimal(base_size = 13)

# 5. Le CA selon le budget pub : la régression et ses deux intervalles ------
modele = lm(chiffre_affaires_eur ~ budget_pub_eur, data = ca)
grille = data.frame(budget_pub_eur = seq(1500, 6500, by = 100))
grille = cbind(grille,
               conf = predict(modele, grille, interval = "confidence")[, 2:3],
               pred = predict(modele, grille, interval = "prediction")[, 2:3])

ggplot(ca, aes(x = budget_pub_eur, y = chiffre_affaires_eur)) +
  geom_ribbon(data = grille, aes(x = budget_pub_eur, ymin = pred.lwr, ymax = pred.upr),
              inherit.aes = FALSE, fill = "steelblue", alpha = 0.15) +
  geom_ribbon(data = grille, aes(x = budget_pub_eur, ymin = conf.lwr, ymax = conf.upr),
              inherit.aes = FALSE, fill = "steelblue", alpha = 0.35) +
  geom_smooth(method = "lm", se = FALSE, colour = "steelblue4") +
  geom_point(size = 2) +
  annotate("point", x = 6000, y = predict(modele, data.frame(budget_pub_eur = 6000)),
           colour = "firebrick", size = 4) +
  annotate("text", x = 6000, y = 36000, label = "6 000 € → 44 100 €\n(39 100 à 49 100 pour une semaine)",
           colour = "firebrick", hjust = 1) +
  scale_x_continuous(labels = euros) + scale_y_continuous(labels = euros) +
  labs(title = "4,5 € de chiffre d'affaires par euro de publicité",
       subtitle = "52 semaines ; bande foncée : CA moyen, bande claire : une semaine donnée (intervalle de prédiction)",
       x = "budget publicitaire hebdomadaire", y = "chiffre d'affaires") +
  theme_minimal(base_size = 13)

# 6. Et le temps : le CA mensuel par canal ----------------------------------
ca_mensuel = aggregate(montant_eur ~ mois + canal, data = commandes, FUN = sum)

ggplot(ca_mensuel, aes(x = mois, y = montant_eur, fill = canal, group = canal)) +
  geom_area(alpha = 0.85, colour = "white") +
  scale_y_continuous(labels = euros) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "D'où vient le chiffre d'affaires, mois par mois",
       x = NULL, y = "CA mensuel", fill = "canal") +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 7. Le "wow" : tout le panier en un graphique, canal × transporteur --------
ggplot(commandes, aes(x = delai_livraison_jours, y = montant_eur, colour = factor(satisfaction))) +
  geom_jitter(width = 0.25, alpha = 0.6, size = 1.3) +
  facet_grid(transporteur ~ canal) +
  scale_y_log10(labels = euros) +
  scale_colour_brewer(palette = "RdYlGn", name = "satisfaction") +
  labs(title = "2 000 commandes, 15 cases, une couleur par note",
       subtitle = "montant (échelle log) selon le délai, pour chaque couple transporteur × canal",
       x = "délai de livraison (jours)", y = "panier") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

# 8. Sauver pour le rapport ---------------------------------------------------
ggsave("ca_vs_budget.png", width = 9, height = 5.5, dpi = 150)   # le dernier graphique affiché

# Pour aller plus loin : esquisse, l'interface clic-bouton qui écrit le code ggplot
# install.packages("esquisse"); esquisse::esquisser(commandes)
