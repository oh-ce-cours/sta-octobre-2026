# Fil rouge, étape 2 : échantillonner (version R)
# Le service client ne peut rappeler que 30 clients. Que vaut le panier moyen, et avec quelle précision ?

commandes = read.table("medias/filRouge/commandes.csv", sep = ";", dec = ",", header = TRUE, fileEncoding = "UTF-8-BOM")

# La « vraie » valeur, qu'on ne connaît jamais en pratique (ici on a les 2 000 commandes) :
mu    = mean(commandes$montant_eur)    # 49.12 €
sigma = sd(commandes$montant_eur)      # 31.01 €

# 1. Chacun tire ses 30 commandes ------------------------------------------
# set.seed(42)                          # à décommenter pour retomber sur le même tirage
echantillon = commandes[sample(nrow(commandes), 30), ]
nrow(echantillon)                       # 30

x    = echantillon$montant_eur
n    = length(x)
xbar = mean(x)                          # VOTRE panier moyen, à noter dans le tableau partagé
s    = sd(x)                            # VOTRE écart-type (divise par n-1, comme ECARTYPE.STANDARD)
xbar; s

# satisfaction moyenne de vos 30 clients
mean(echantillon$satisfaction)

# 2. Votre intervalle de confiance à 95 % ----------------------------------
# à la main : xbar ± t(0.975, n-1) × s / racine(n)
erreur_standard = s / sqrt(n)
t_critique = qt(0.975, df = n - 1)      # 2.045 (Excel : LOI.STUDENT.INVERSE.BILATERALE(0,05;29))
c(xbar - t_critique * erreur_standard, xbar + t_critique * erreur_standard)

# la même chose en une ligne :
t.test(x)$conf.int

# l'intervalle contient-il le vrai panier moyen ?
ic = t.test(x)$conf.int
ic[1] <= mu & mu <= ic[2]               # TRUE ou FALSE : à dire au formateur

# 3. Le tableau de la salle --------------------------------------------------
# Collez ici les moyennes et écarts-types de chacun (exemple avec 8 stagiaires) :
moyennes_salle    = c(56.7, 44.2, 51.9, 47.3, 60.1, 42.8, 49.5, 53.0)
ecarts_types_salle = c(43.7, 25.1, 33.8, 28.9, 39.2, 24.4, 30.6, 35.5)

mean(moyennes_salle)                    # proche de 49.12 : les moyennes tournent autour de la vérité
sd(moyennes_salle)                      # l'écart-type DES MOYENNES : à comparer à...
sigma / sqrt(30)                        # 5.66 : l'erreur standard théorique
mean(ecarts_types_salle)                # les s tournent autour de 31

# combien d'intervalles de la salle contiennent 49.12 ?
bas  = moyennes_salle - 2.045 * ecarts_types_salle / sqrt(30)
haut = moyennes_salle + 2.045 * ecarts_types_salle / sqrt(30)
data.frame(moyenne = moyennes_salle, bas = round(bas, 1), haut = round(haut, 1), contient_mu = bas <= mu & mu <= haut)
sum(bas <= mu & mu <= haut)             # sur 8, on en attend 7 ou 8 (95 %)

# 4. Ce que la salle fait 8 fois, R le fait 1 000 fois --------------------
# Une boucle : à chaque tour, un nouveau stagiaire imaginaire tire 30 commandes
# et note sa moyenne, son écart-type et si son intervalle contient 49.12 €.

nb_tirages = 1000
moyennes    = numeric(nb_tirages)       # trois vecteurs vides, un par chose à noter
ecarts_types = numeric(nb_tirages)
contient_mu  = logical(nb_tirages)

for (i in 1:nb_tirages) {
  x = sample(commandes$montant_eur, 30)         # le tirage numéro i
  moyennes[i]     = mean(x)                     # on note sa moyenne dans la case i
  ecarts_types[i] = sd(x)                       # et son écart-type
  bas  = moyennes[i] - 2.045 * ecarts_types[i] / sqrt(30)
  haut = moyennes[i] + 2.045 * ecarts_types[i] / sqrt(30)
  contient_mu[i]  = (bas <= mu) & (mu <= haut)  # TRUE si l'intervalle contient la vraie valeur
}

head(data.frame(moyennes, ecarts_types, contient_mu))   # les 6 premiers tirages

mean(moyennes)          # ≈ 49.1 : pas de biais, les moyennes tournent autour de la vérité
sd(moyennes)            # ≈ 5.6  : l'erreur standard, sigma / racine(30)
mean(ecarts_types)      # ≈ 30.2 : s estime sigma (31.0), un peu en dessous en moyenne
mean(contient_mu)       # ≈ 0.93 : la part des intervalles qui contiennent 49.12 €
                        #   (un peu moins que 95 % : panier très asymétrique et n = 30 petit)

hist(moyennes, breaks = 30, main = "1 000 paniers moyens de 30 commandes", xlab = "€")
abline(v = mu, col = "firebrick", lwd = 2)
# la distribution du panier était très asymétrique (étape 1) ; celle des moyennes est en cloche : TCL

# et avec n = 100 ? La même boucle, on change juste n
n = 100
moyennes100 = numeric(nb_tirages)
contient100 = logical(nb_tirages)
for (i in 1:nb_tirages) {
  x = sample(commandes$montant_eur, n)
  moyennes100[i] = mean(x)
  bas  = mean(x) - qt(0.975, n - 1) * sd(x) / sqrt(n)
  haut = mean(x) + qt(0.975, n - 1) * sd(x) / sqrt(n)
  contient100[i] = (bas <= mu) & (mu <= haut)
}
sd(moyennes100)         # ≈ 3.1 : sigma / racine(100). Quatre fois plus de clients, erreur divisée par deux (pas par quatre)
mean(contient100)       # ≈ 0.95

# Version courte, une fois la boucle comprise (c'est ce que fait l'animation) :
# moyennes = replicate(1000, mean(sample(commandes$montant_eur, 30)))

# 5. Combien de clients rappeler pour connaître le panier moyen à ± 5 € ? à ± 2 € ?
# on isole n dans la demi-largeur e = z × sigma / racine(n)
e = 5;  ceiling((1.96 * sigma / e)^2)   # 148 clients
e = 2;  ceiling((1.96 * sigma / e)^2)   # 924 clients
# en pratique on ne connaît pas sigma : on prend le s d'un premier petit échantillon, ou power.t.test :
power.t.test(delta = 5, sd = sigma, sig.level = 0.05, power = 0.8, type = "one.sample")
