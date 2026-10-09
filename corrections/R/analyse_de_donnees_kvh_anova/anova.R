library(readr)

# timeseries
library(xts)

# pairwise
library("psych")

# HSD
library(agricolae)


Exo_kvh <- read_delim(
      "Exo_kvh.csv", 
      ";", 
      escape_double = FALSE, 
      col_types = cols(
          Machine = col_character(), 
          article = col_character(), 
          couleur = col_character(), 
          `date de production` = col_date(format = "%d/%m/%Y"), 
          filaments = col_character()
      ), 
      locale = locale(
          date_names = "fr", 
          decimal_mark = ","
      ), 
      trim_ws = TRUE
)

# la première ligne est en 2008 les autres en 2016...
Exo_kvh = Exo_kvh[-1, ]

# R veut que les facteurs de l'anova soient dans une colonne et les valeurs mesurée dans une autre
# actuellement on a des valeurs dans des colonnes différentes, on utilise la fonction "stack" pour 
# formater comme il faut facilement. 

# pour cela, on ne concerve que les colonnes qui correspondent aux facteurs
kvhs = Exo_kvh[c(8:18)]
stacked_kvh = stack(kvhs)

#############################
## Exploration
#############################

# colonnes d'intéret
cols = c("date de production", "KWH 1AV", "KWH 1AR",           
"KWH 2AV", "KWH 2AR", "KWH 3AV",      
"KWH 3AR", "KWH 4AV", "KWH 4AR",     
"KWH 5AV", "KWH 5AR", "KWH 6AV",    
"KWH 6AR")

summary(Exo_kvh[cols[-1]])

# pairwise correlations
pairs.panels(Exo_kvh[cols[-1]], 
             method = "pearson", # correlation method
             hist.col = "#00AFBB",
             density = TRUE,  # show density plots
             ellipses = TRUE # show correlation ellipses
)

# boxplot des kvh en fonction de la position / machine
boxplot(values ~ ind, data=stacked_kvh)

### on remarque que certaines machines ont une meilleure corrélation 
### entre position AV et AR (1 est "meilleure" que 4 ou 5).

### Il y a un problème avec les échelles, ont peut croire qu'une des
### machine à une moyenne différente dans le pairs.panel alors que le summary nous dit le 
### contraire. 
### 4AV à une valeur potentiellement abbérente 
### (son minimum que l'on peut voir sur le boxplot et le summary)
### Il faudrait probablement supprimer cet élément avant de faire l'ANOVA pour
### ne pas perturber le résultat de l'analyse (je ne l'ai pas fait)


#############################
## ANOVA
#############################

model = aov(values~ind, data=stacked_kvh)
res = anova(model)

# Analysis of Variance Table
#
# Response: values
# Df  Sum Sq Mean Sq F value    Pr(>F)    
# ind          10   200.1 20.0064   17.52 < 2.2e-16 ***
# Residuals 10825 12361.1  1.1419                      
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

## => Pval < 2.2*10⁻16 donc il y a une différence entre les machines 

### Quelle sont les groupes

#### 1ère approche
TukeyHSD(x=model, conf.level=0.95)
plot(TukeyHSD(x=model, conf.level=0.95))

#### 2nd approche (bibliothèque externe)
HSD.test(model, "ind", console=T)

# Treatments with the same letter are not significantly different.
# values groups
# KWH 4AR 19.80124      a
# KWH 1AV 19.57554      b
# KWH 1AR 19.53370     bc
# KWH 6AV 19.52591     bc
# KWH 5AR 19.50213    bcd
# KWH 2AR 19.49693    bcd
# KWH 4AV 19.46848   bcde
# KWH 2AV 19.38920   cdef
# KWH 3AR 19.36162    def
# KWH 3AV 19.33176     ef
# KWH 5AV 19.27749      f



#############################
## Analyse en fonction du temps
#############################


## il y a eaucoup de couleurs à gérer. On crée une palette
color_pallete_function <- colorRampPalette(
  colors = c("black", "red", "green", "blue"),
  space = "rgb"
)

num_colors <- nlevels(stacked_kvh$ind)
colors <- color_pallete_function(num_colors)

plot(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 1AV`, type="l", col=colors[1])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 1AR`, type="l", col=colors[2])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 2AV`, type="l", col=colors[3])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 2AR`, type="l", col=colors[4])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 3AV`, type="l", col=colors[5])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 3AR`, type="l", col=colors[6])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 4AV`, type="l", col=colors[7])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 4AR`, type="l", col=colors[8])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 5AV`, type="l", col=colors[9])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 5AR`, type="l", col=colors[10])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 6AV`, type="l", col=colors[11])
lines(x=Exo_kvh$`date de production`, y=Exo_kvh$`KWH 6AR`, type="l", col=colors[12])

#locator()
legend("topleft", legend=c("1AV", "1AR", "2AV", "2AR", "3AV", "3AR", "4AV", "4AR", "5AV", "5AR", "6AV", "6AR"),
       col=colors, lty=1, cex=0.8)

## On remarque que les KWH semblent tous bouger en même temps.
## Les machines ne doivent pas être indépendantes 
## (matériel en entrée ou réglages en même temps)

## Il faudrait faire d'autre types de visualisations / analyses pour avoir une idée plus précise
## mais cela est hors programme.
