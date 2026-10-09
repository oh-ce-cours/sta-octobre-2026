###########################################################################
##### Risque alpha
###########################################################################

# déclaration des variables

## le risque alpha que l'on a choisi
threshold = 10 / 100

## un compteur du nombre de fois où l'on a pas refusé H0
nb_ok = 0

## le nombre d'itérations
nbs=1000

## la taille de l'échantillon aléatoire que l'on tire
size = 30


# on fait une boucle sur le nobre d'éléments défini juste avant
# cela va répéter autant de fois son contenu
for(i in 1:nbs){
    # on tire N nombres dans une loi normale, centrée réduite
    xs = rnorm(size, 0, 1)

    # si la pvalue est plus grande que le seuil
    # on considère que l'échantillon suit une loi de moyenne nulle
    # on ne rejette pas H0...
    if(t.test(xs)$p.val > threshold){
        nb_ok = nb_ok + 1
    }
}

# on affiche le résultat
print(paste(paste("Correct dans", 100 * nb_ok / nbs), "% des fois"))


## explication

# la pvalue se compare au risque de 1ere espèce,
# c'est à dire les faux positifs, ou refuser quelque chose qui est
# pourtant vrai.

# dans notre cas, l'échantillon est issue d'une loi centrée réduite,
# pourtant nous avons un taux de bonne réponse correspondant à 1 - alpha.
# C'est donc logique.








###################################################
# Risque beta
###################################################


# déclaration des variables

## le risque alpha que l'on a choisi
threshold = 5 / 100

## un compteur du nombre de fois où l'on a pas refusé H0
nb_ok = 0

## le nombre d'itérations
nbs=10000

## la taille de l'échantillon aléatoire que l'on tire
size = 5

## moyenne réelle de la population (effet)
m = 10


# on fait une boucle sur le nobre d'éléments défini juste avant
# cela va répéter autant de fois son contenu
for(i in 1:nbs){
    # on tire N nombres dans une loi normale, réduite et de moyenne m
    xs = rnorm(size, m, 1)

    # si la pvalue est plus petite que le seuil
    # on considère que l'échantillon ne suit pas une loi de moyenne nulle
    # on rejette H0...
    if(t.test(xs)$p.val < threshold){
        nb_ok = nb_ok + 1
    }
}

# on affiche le résultat
print(paste(paste("Correct dans", 100 * nb_ok / nbs), "% des fois"))


## explication

# dans ce cas, notre population n'a pas une moyenne nulle
# pourtant dans certains cas, nous disons que sa moyenne est effectivement nulle.

# Cela n'a pas d'impact clair avec le seuil que nous définissons pour le rejet
# de l'hypothèse nulle.

# En effet, cela est lié au risque de deuxième espèce.
# On ne peut pas le calculer facilement. Cependant, on remarque qu'en augmentant
# alpha, l'effet (la moyenne de la population) ou la taille de l'échantillon, le nombre
# de décisions correctes augemente.



## Conclusion

# Selon les conclusions que l'on veut mettre en avant, on essayera de
# maximiser le risque qui nous intéresse, soit en modifiant la taille de l'échantillon
# soit en modifiant le risque que l'on est prêt à prendre.