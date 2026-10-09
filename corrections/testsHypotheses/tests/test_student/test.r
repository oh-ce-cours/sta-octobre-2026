
## on teste si la moyenne de l'usine 1 est 53
t.test(cure_dent_usine_1, mu=53)

# 	One Sample t-test

# data:  cure_dent_usine_1
# t = 1.8295, df = 99, p-value = 0.07033
# alternative hypothesis: true mean is not equal to 53
# 95 percent confidence interval:
#  52.95305 54.15748
# sample estimates:
# mean of x
#  53.55526
## on ne peut pas dire que non avec un risque de 5%




## on teste si la moyenne de l'usine 2 est 53
t.test(cure_dent_usine_2, mu=53)

# 	One Sample t-test

# data:  cure_dent_usine_2
# t = 13.968, df = 99, p-value < 2.2e-16
# alternative hypothesis: true mean is not equal to 53
# 95 percent confidence interval:
#  56.55227 57.72858
# sample estimates:
# mean of x
#  57.14042
## on peut dire que non avec un risque de 5%




## on teste si les usines fabriquent des cure dents de même longeur :
## R choisit le test adapté automatiquement (les variances ne sont pas égales dans l'échantillon)
t.test(cure_dent_usine_1, cure_dent_usine_2)

# 	Welch Two Sample t-test

# data:  cure_dent_usine_1 and cure_dent_usine_2
# t = -8.4508, df = 197.89, p-value = 6.229e-15
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#  -4.421766 -2.748554
# sample estimates:
# mean of x mean of y
#  53.55526  57.14042
## on peut dire que non avec un risque de 5%




## on regarde même en utilisant le mauvais type de test
t.test(cure_dent_usine_1, cure_dent_usine_2, var.equal=T)

# 	Two Sample t-test

# data:  cure_dent_usine_1 and cure_dent_usine_2
# t = -8.4508, df = 198, p-value = 6.214e-15
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#  -4.421763 -2.748557
# sample estimates:
# mean of x mean of y
#  53.55526  57.14042
## Ca ne change pas grand chose