# des_comptage = c(rep(1, 5), rep(2, 8), rep(3, 4), rep(4, 6), rep(5, 4), rep(6, 7))

# on regarde la distribution des faces
hist(des_comptage, breaks=seq(0.5, 6.5, 1))

# on compte le nombre de répétitions pour chaques faces
counts = table(des_comptage)

# on regarde si la probabilité suit une loi uniforme
chisq.test(counts)

# 	Chi-squared test for given probabilities

# data:  counts
# X-squared = 2.3529, df = 5, p-value = 0.7985

## on ne peut pas rejetter H0, on n'a pas montré que le dé était truqué