## on fit le modèle, ANOVA à un facteur
model = aov(fievre~traitement, data=total)
model
# Call:
#    aov(formula = fievre ~ traitement, data = total)

# Terms:
#                 traitement Residuals
# Sum of Squares    64.35597 195.54226
# Deg. of Freedom          2       147

# Residual standard error: 1.153351
# Estimated effects may be unbalanced


## on calcule l'anova
anova(model)
# Analysis of Variance Table

# Response: fievre
#             Df  Sum Sq Mean Sq F value    Pr(>F)
# traitement   2  64.356  32.178   24.19 8.282e-10 ***
# Residuals  147 195.542   1.330
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
## La pvalue est inférieure à 5%, on rejette H0, il y a un effet du médicament sur la fièvre

## on regarde l'effet des différentes modalités
library(agricolae)
effet_medicament = HSD.test(model, "traitement", console=T)

# Study: model ~ "traitement"

# HSD Test for fievre

# Mean Square Error:  1.330219

# traitement,  means

#             fievre       std  r      Min      Max
# dose_1000 38.27293 1.1916905 50 35.53704 40.77079
# dose_500  39.09837 1.3584788 50 35.41878 41.90241
# temoin    39.87715 0.8515089 50 37.85565 41.85278

# Alpha: 0.05 ; DF Error: 147
# Critical Value of Studentized Range: 3.348424

# Minimun Significant Difference: 0.5461565

# Treatments with the same letter are not significantly different.

#             fievre groups
# temoin    39.87715      a
# dose_500  39.09837      b
# dose_1000 38.27293      c


## on regarde les différents groupes
plot(effet_medicament)

## dans notre cas, la différence est tellement petite
## qu'on ne peut pas la voir à l'oeil
## (la température du corps humain à une toute petite variabilité)


## on fait un test de Student entre les 2 doses pour voir laquelle est la plus efficace
t.test(dose_500, dose_1000, alternative="g")

# 	Welch Two Sample t-test

# data:  dose_500 and dose_1000
# t = 3.2299, df = 96.365, p-value = 0.0008471
# alternative hypothesis: true difference in means is greater than 0
# 95 percent confidence interval:
#  0.4009965       Inf
# sample estimates:
# mean of x mean of y
#  39.09837  38.27293
## La dose à 1000mg est plus efficace que celle à 500