import numpy as np, pandas as pd, sys
from scipy import stats
d = sys.argv[1]
c = pd.read_csv(f"{d}/commandes.csv", sep=";", decimal=",")
v = pd.read_csv(f"{d}/visitesAB.csv", sep=";", decimal=",")
w = pd.read_csv(f"{d}/caHebdo.csv", sep=";", decimal=",")
print(c.head(3)); print(w.head(3))
m = c.montant_eur
print("\n== ETAPE 1 DECRIRE")
print("panier moyen", m.mean().round(2), "médiane", m.median().round(2), "mode arrondi", m.round(-1).mode().values, "sd", m.std().round(2), "min/max", m.min(), m.max())
print("quartiles", m.quantile([.25,.5,.75]).round(2).values, "IQR", (m.quantile(.75)-m.quantile(.25)).round(2), "P90", m.quantile(.9).round(2), "P99", m.quantile(.99).round(2))
print("part du CA faite par les 10% plus gros paniers", (m[m>=m.quantile(.9)].sum()/m.sum()).round(3))
print("skew", stats.skew(m).round(2))
print("effectifs canal\n", c.canal.value_counts()); print("freq canal\n", c.canal.value_counts(normalize=True).round(3))
print("CA par canal\n", c.groupby("canal").montant_eur.agg(["count","mean","median","sum"]).round(2))
print("delai par transporteur\n", c.groupby("transporteur").delai_livraison_jours.agg(["count","mean","median","std","min","max"]).round(2))
print("satisfaction moyenne", c.satisfaction.mean().round(3), c.satisfaction.value_counts(normalize=True).sort_index().round(3).to_dict())
print("classes montant (0-25,25-50,...)", np.histogram(m, bins=[0,25,50,75,100,150,200,300,500,10000])[0])
print("corr delai-satisfaction", np.corrcoef(c.delai_livraison_jours, c.satisfaction)[0,1].round(3))
print("corr nb_articles-montant", np.corrcoef(c.nb_articles, m)[0,1].round(3))

print("\n== ETAPE 2 ECHANTILLONNER (population = 2000 commandes)")
pop = m.values; mu = pop.mean(); sig = pop.std(ddof=0)
rng = np.random.default_rng(1)
for n in (10, 30, 100):
    means = np.array([rng.choice(pop, n, replace=False).mean() for _ in range(2000)])
    print(f"n={n}: moyenne des moyennes {means.mean():.2f}, sd des moyennes {means.std():.2f}, sigma/sqrt(n) {sig/np.sqrt(n):.2f}, skew {stats.skew(means):.2f}, IC empirique 95% [{np.percentile(means,2.5):.1f}, {np.percentile(means,97.5):.1f}]")
n=30; cov=0
for _ in range(2000):
    s = rng.choice(pop, n, replace=False); t=stats.t.ppf(.975, n-1); se=s.std(ddof=1)/np.sqrt(n)
    cov += (s.mean()-t*se <= mu <= s.mean()+t*se)
print("couverture IC95 n=30", cov/2000)
s30 = c.montant_eur.values[:30]; t=stats.t.ppf(.975,29); se=s30.std(ddof=1)/np.sqrt(30)
print("30 premières commandes : moyenne", s30.mean().round(2), "sd", s30.std(ddof=1).round(2), "erreur std", se.round(2), "t", t.round(3), "IC95", (s30.mean()-t*se).round(2), (s30.mean()+t*se).round(2), "vrai mu", mu.round(2))
# satisfaction sur 30 premières
sat30 = c.satisfaction.values[:30]; se=sat30.std(ddof=1)/np.sqrt(30)
print("satisfaction 30 premières : moyenne", sat30.mean().round(2), "IC95", (sat30.mean()-t*se).round(2), (sat30.mean()+t*se).round(2), "vraie", c.satisfaction.mean().round(2))
# taille d'échantillon pour +-5 € à 95%
print("n pour marge 5€ à 95% :", np.ceil((1.96*m.std()/5)**2), "; marge 2€ :", np.ceil((1.96*m.std()/2)**2))

print("\n== ETAPE 3 MODELISER : CA ~ budget pub")
x, y = w.budget_pub_eur.values.astype(float), w.chiffre_affaires_eur.values.astype(float)
r = stats.linregress(x, y); n=len(x)
print("pente", r.slope.round(3), "ordonnée", r.intercept.round(0), "r", r.rvalue.round(3), "R2", (r.rvalue**2).round(3), "p", r.pvalue, "se pente", r.stderr.round(3))
tt = stats.t.ppf(.975, n-2); print("IC95 pente", (r.slope-tt*r.stderr).round(2), (r.slope+tt*r.stderr).round(2))
resid = y - (r.intercept + r.slope*x); s_res = np.sqrt((resid**2).sum()/(n-2)); print("écart-type résiduel", s_res.round(0))
for x0 in (3000, 6000, 8000):
    y0 = r.intercept + r.slope*x0; sxx=((x-x.mean())**2).sum()
    sem = s_res*np.sqrt(1/n + (x0-x.mean())**2/sxx); sep = s_res*np.sqrt(1+1/n+(x0-x.mean())**2/sxx)
    print(f"budget {x0}: CA prévu {y0:.0f}, IC95 moyenne [{y0-tt*sem:.0f},{y0+tt*sem:.0f}], IP95 [{y0-tt*sep:.0f},{y0+tt*sep:.0f}]")
print("shapiro résidus", stats.shapiro(resid).pvalue.round(3), "corr résidus-x", np.corrcoef(resid, x)[0,1].round(3))
print("budget min/max", x.min(), x.max(), "CA moyen", y.mean().round(0))
print("ROI marginal : 1€ de pub -> ", r.slope.round(2), "€ de CA")

print("\n== ETAPE 4 TESTER")
ct = pd.crosstab(v.version_page, v.achat); print(ct)
pa, pb = ct.loc["A","oui"]/ct.loc["A"].sum(), ct.loc["B","oui"]/ct.loc["B"].sum()
print("conv A", pa.round(4), "conv B", pb.round(4), "n", ct.loc["A"].sum(), ct.loc["B"].sum())
chi2, p, dof, exp = stats.chi2_contingency(ct, correction=False); print("chi2 sans correction", chi2.round(3), "p", p.round(4))
chi2c, pc, _, _ = stats.chi2_contingency(ct, correction=True); print("chi2 Yates (prop.test R)", chi2c.round(3), "p", pc.round(4))
# IC diff proportions
na, nb = ct.loc["A"].sum(), ct.loc["B"].sum(); se = np.sqrt(pa*(1-pa)/na + pb*(1-pb)/nb); print("diff B-A", (pb-pa).round(4), "IC95", ((pb-pa)-1.96*se).round(4), ((pb-pa)+1.96*se).round(4))
# IC de chaque proportion
for k,pp,nn in (("A",pa,na),("B",pb,nb)): print(f"IC95 conv {k}", (pp-1.96*np.sqrt(pp*(1-pp)/nn)).round(4), (pp+1.96*np.sqrt(pp*(1-pp)/nn)).round(4))
# taille d'échantillon pour détecter 3% vs 4% à 80% de puissance
from scipy.stats import norm
p1,p2=0.03,0.04; pbar=(p1+p2)/2
n_needed = ((norm.ppf(.975)*np.sqrt(2*pbar*(1-pbar)) + norm.ppf(.8)*np.sqrt(p1*(1-p1)+p2*(1-p2)))/(p2-p1))**2
print("n par version pour détecter 3%->4% (alpha 5%, puissance 80%)", np.ceil(n_needed))
# Student delai Colissimo vs Chronopost
co, ch = c[c.transporteur=="Colissimo"].delai_livraison_jours, c[c.transporteur=="Chronopost"].delai_livraison_jours
tw = stats.ttest_ind(co, ch, equal_var=False); print("Welch Colissimo vs Chronopost", tw.statistic.round(2), tw.pvalue, "df", tw.df.round(1), "diff", (co.mean()-ch.mean()).round(2), "IC95", tw.confidence_interval().low.round(2), tw.confidence_interval().high.round(2))
mr = c[c.transporteur=="Mondial Relay"].delai_livraison_jours
tw2 = stats.ttest_ind(co, mr, equal_var=False); print("Welch Colissimo vs Mondial Relay", tw2.statistic.round(2), tw2.pvalue, "diff", (co.mean()-mr.mean()).round(2), "IC95", tw2.confidence_interval().low.round(2), tw2.confidence_interval().high.round(2))
# Student: panier moyen vs objectif 50 €
t1 = stats.ttest_1samp(m, 50); print("panier moyen vs 50€", t1.statistic.round(2), t1.pvalue, "IC95", t1.confidence_interval().low.round(2), t1.confidence_interval().high.round(2))
# ANOVA panier par canal
groups = [g.montant_eur.values for _, g in c.groupby("canal")]
f = stats.f_oneway(*groups); print("ANOVA montant~canal F", f.statistic.round(2), "p", f.pvalue)
print("moyennes canal", c.groupby("canal").montant_eur.mean().round(2).to_dict())
th = stats.tukey_hsd(*groups); names = sorted(c.canal.unique()); 
for i in range(5):
    for j in range(i+1,5):
        if th.pvalue[i,j] < 0.05: print("  Tukey signif:", names[i], "vs", names[j], "diff", (groups[i].mean()-groups[j].mean()).round(2), "p", th.pvalue[i,j].round(4))
# ANOVA sur log(montant) (adéquation)
fl = stats.f_oneway(*[np.log(g) for g in groups]); print("ANOVA log(montant)~canal F", fl.statistic.round(2), "p", fl.pvalue)
kw = stats.kruskal(*groups); print("Kruskal-Wallis", kw.statistic.round(2), kw.pvalue)
# chi2 satisfaction x transporteur
c["satisfait"] = np.where(c.satisfaction>=4, "satisfait (4-5)", "non satisfait (1-3)")
ct2 = pd.crosstab(c.transporteur, c.satisfait); print(ct2); print("part satisfaits\n", (ct2.iloc[:,1]/ct2.sum(axis=1)).round(3))
chi2b, pb2, dofb, expb = stats.chi2_contingency(ct2); print("chi2 satisf x transporteur", chi2b.round(2), "p", pb2, "dof", dofb); print("attendus\n", expb.round(1))
ct3 = pd.crosstab(c.canal, c.client_nouveau); chi3 = stats.chi2_contingency(ct3); print("chi2 canal x nouveau", chi3[0].round(1), chi3[1])

print("\n== ETAPE 5 ADEQUATION")
print("montant : shapiro p", stats.shapiro(m.sample(500, random_state=0)).pvalue, "skew", stats.skew(m).round(2))
print("log(montant) : shapiro p", stats.shapiro(np.log(m.sample(500, random_state=0))).pvalue.round(3), "skew", stats.skew(np.log(m)).round(2))
mu_, sd_ = m.mean(), m.std(); print("si normale : P(montant<0) =", stats.norm.cdf(0, mu_, sd_).round(3), "; P(>200) normale", (1-stats.norm.cdf(200, mu_, sd_)).round(3), "observé", (m>200).mean().round(3))
edges=[0,25,50,75,100,150,200,300,1e9]; obs=np.histogram(m, bins=edges)[0]
exp_n = np.diff(stats.norm.cdf(edges, mu_, sd_))*len(m); exp_n[0]=stats.norm.cdf(25,mu_,sd_)*len(m)
lm_, ls_ = np.log(m).mean(), np.log(m).std(); exp_l = np.diff(stats.lognorm.cdf(edges, s=ls_, scale=np.exp(lm_)))*len(m)
print("classes", edges); print("obs", obs); print("attendu normale", exp_n.round(0)); print("attendu log-normale", exp_l.round(0))
print("chi2 adéquation normale p", stats.chisquare(obs, exp_n/exp_n.sum()*obs.sum(), ddof=2).pvalue, "; log-normale p", stats.chisquare(obs, exp_l/exp_l.sum()*obs.sum(), ddof=2).pvalue.round(4))
print("delai colissimo shapiro", stats.shapiro(co).pvalue, "skew", stats.skew(co).round(2), "mais n=", len(co))
print("médiane montant", m.median().round(2), "exp(moyenne log)", np.exp(lm_).round(2))
