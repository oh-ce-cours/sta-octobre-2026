## ampoules = rnorm(50, 4000, 100)
## ampoules_concurrent = rnorm(50, 4100, 100)


############################################################
#### Intervalle de confiance d'une moyenne
############################################################

mean(ampoules)
# [1] 3988.904


t.test(ampoules)

# 	One Sample t-test

# data:  ampoules
# t = 252.67, df = 49, p-value < 2.2e-16
# alternative hypothesis: true mean is not equal to 0
# 95 percent confidence interval:
#  3957.180 4020.629
# sample estimates:
# mean of x
#  3988.904

sd(ampoules)
# [1] 111.6291

qt(1-0.01/2, 49)
# [1] 2.679952
qt(0.95, 49)
# [1] 1.676551
qt(0.975, 49)
# [1] 2.009575

3988.904 + 2.009575 * 111.6291/sqrt(50)
# [1] 4020.629




t.test(ampoules, conf.level=0.99)

# 	One Sample t-test

# data:  ampoules
# t = 252.67, df = 49, p-value < 2.2e-16
# alternative hypothesis: true mean is not equal to 0
# 99 percent confidence interval:
#  3946.597 4031.212
# sample estimates:
# mean of x
#  3988.904



t.test(ampoules, conf.level=0.90)

# 	One Sample t-test

# data:  ampoules
# t = 252.67, df = 49, p-value < 2.2e-16
# alternative hypothesis: true mean is not equal to 0
# 90 percent confidence interval:
#  3962.437 4015.372
# sample estimates:
# mean of x
#  3988.904


## calcul des différents IC
> 3988.904 + 2.679952 * 111.6291/sqrt(50)
# [1] 4031.212
> 3988.904 + 1.676551 * 111.6291/sqrt(50)
# [1] 4015.371
> 3988.904 + 1.676551 * 111.6291/sqrt(50)


############################################################
#### Intervalle de confiance d'une différence de moyenne
############################################################

## comparaison des moyennes
> t.test(ampoules, ampoules_concurrent)

# 	Welch Two Sample t-test

# data:  ampoules and ampoules_concurrent
# t = -4.0371, df = 97.75, p-value = 0.0001076
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#  -137.97062  -47.02895
# sample estimates:
# mean of x mean of y
#  3988.904  4081.404

## différence des moyennes
3988.904 - 4081.404
# [1] -92.5

#
sd(ampoules)**2
[1] 12461.05
> sqrt(sd(ampoules)**2 / 50 + sd(ampoules_concurrent) / 50)
[1] 15.86094
> ?qt(
+
> qt(1-0.05/2, 49+49)
[1] 1.984467
> -92.5 + 15.86094 * 1.984467
[1] -61.02449
> -92.5 - 15.86094 * 1.984467
[1] -123.9755
> qt(1-0.05/2, 97.75)
[1] 1.984531
> -92.5 - 15.86094 * 1.984531
[1] -123.9765
> sd(ampoules)
[1] 111.6291


## calcul de l'erreur
sqrt(sd(ampoules)*sd(ampoules)/50 + sd(ampoules_concurrent)*sd(ampoules_concurrent)/50)
# [1] 22.91264
> -92.5 - 22.91264 * 1.984531
# [1] -137.9708
> -92.5 + 22.91264 * 1.984531
# [1] -47.02916




############################################################
#### Intervalle de confiance d'une proportion
############################################################

prop.test(3, 50)

# 	1-sample proportions test with continuity correction

# data:  3 out of 50, null probability 0.5
# X-squared = 36.98, df = 1, p-value = 1.193e-09
# alternative hypothesis: true p is not equal to 0.5
# 95 percent confidence interval:
#  0.01562459 0.17541874
# sample estimates:
#    p
# 0.06


## calcul de p
3/50
[1] 0.06

## calcul de 1-p
1-3/50
# [1] 0.94

sqrt(0.94*0.06/50)
# [1] 0.03358571

## calcul de z
pc = qnorm(0.975)
pc
# [1] 1.959964

## calcul des IC
p + pc * sqrt(p*(1-p)/50)
[1] 0.1258268
> p - pc * sqrt(p*(1-p)/50)
[1] -0.005826784


install.packages('binom')
library(binom)

binom.confint(3, 50)
#           method x  n       mean        lower     upper
# 1  agresti-coull 3 50 0.06000000  0.014420714 0.1683652
# 2     asymptotic 3 50 0.06000000 -0.005826784 0.1258268
# 3          bayes 3 50 0.06862745  0.010699356 0.1376543
# 4        cloglog 3 50 0.06000000  0.015682958 0.1488348
# 5          exact 3 50 0.06000000  0.012548588 0.1654819
# 6          logit 3 50 0.06000000  0.019480341 0.1701741
# 7         probit 3 50 0.06000000  0.017542810 0.1581287
# 8        profile 3 50 0.06000000  0.015303616 0.1482785
# 9            lrt 3 50 0.06000000  0.015291827 0.1482746
# 10     prop.test 3 50 0.06000000  0.015624594 0.1754187
# 11        wilson 3 50 0.06000000  0.020614970 0.1621709
