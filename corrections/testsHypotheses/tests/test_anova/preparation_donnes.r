temoin = rnorm(50, 40, 1)
dose_500 = rnorm(50, 39, 1.5)
dose_1000 = rnorm(50, 38.5, 1.2)

d_temoin = data.frame(fievre=temoin, traitement=rep("temoin", length(temoin)))
d_dose500 = data.frame(fievre=dose_500, traitement=rep("dose_500", length(temoin)))
d_dose1000 = data.frame(fievre=dose_1000, traitement=rep("dose_1000", length(temoin)))

total = rbind(d_temoin, d_dose500)
total = rbind(total, d_dose1000)