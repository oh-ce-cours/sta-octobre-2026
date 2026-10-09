"""Génération reproductible des données du fil rouge « boutique en ligne ».
Trois fichiers : commandes.csv, visitesAB.csv, caHebdo.csv (séparateur ; décimale ,)."""
import numpy as np, pandas as pd, sys
from pathlib import Path
out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
rng = np.random.default_rng(20250925)

# ---------- commandes.csv ----------
n = 2000
canaux = rng.choice(["SEO", "SEA", "Email", "Réseaux sociaux", "Direct"], n, p=[0.32, 0.23, 0.18, 0.12, 0.15])
regions = rng.choice(["Île-de-France", "Auvergne-Rhône-Alpes", "Hauts-de-France", "Nouvelle-Aquitaine", "Occitanie", "Bretagne", "Grand Est", "PACA"], n,
                     p=[0.24, 0.14, 0.11, 0.10, 0.10, 0.08, 0.11, 0.12])
transporteur = rng.choice(["Colissimo", "Chronopost", "Mondial Relay"], n, p=[0.5, 0.2, 0.3])
nb_articles = rng.poisson(1.6, n) + 1
# panier : log-normale, légèrement plus élevé pour Email (clients fidèles) et croissant avec nb_articles
base = 3.55 + 0.22 * np.log(nb_articles) + np.where(canaux == "Email", 0.12, 0.0) + np.where(canaux == "Réseaux sociaux", -0.08, 0.0)
montant = np.round(np.exp(rng.normal(base, 0.55)), 2)
montant = np.clip(montant, 4.9, None)
# délai de livraison (jours) : dépend du transporteur, asymétrique
delai_mu = {"Colissimo": 2.9, "Chronopost": 1.4, "Mondial Relay": 3.6}
delai = np.array([max(1, round(rng.gamma(shape=6, scale=delai_mu[t] / 6) + 0.3)) for t in transporteur])
# satisfaction 1-5 : baisse avec le délai
p_sat = 4.55 - 0.32 * delai + rng.normal(0, 0.7, n)
satisfaction = np.clip(np.round(p_sat), 1, 5).astype(int)
client_nouveau = rng.random(n) < np.where(canaux == "Email", 0.15, 0.55)
dates = pd.Timestamp("2025-01-06") + pd.to_timedelta(rng.integers(0, 364, n), unit="D")
ids = [f"CMD-{d.strftime('%y%m%d')}-{rng.integers(1000, 9999)}" for d in dates]
commandes = pd.DataFrame({
    "id_commande": ids, "date": dates.strftime("%d/%m/%Y"), "canal": canaux, "region": regions,
    "transporteur": transporteur, "nb_articles": nb_articles, "montant_eur": montant,
    "delai_livraison_jours": delai, "satisfaction": satisfaction, "client_nouveau": np.where(client_nouveau, "oui", "non"),
}).sort_values("date", key=lambda s: pd.to_datetime(s, dayfirst=True)).reset_index(drop=True)
commandes.to_csv(out / "commandes.csv", sep=";", decimal=",", index=False, encoding="utf-8-sig")

# ---------- visitesAB.csv ----------
nv = 4000
version = rng.choice(["A", "B"], nv)
p_conv = np.where(version == "A", 0.031, 0.041)
achat = rng.random(nv) < p_conv
visites = pd.DataFrame({"id_visite": np.arange(100001, 100001 + nv), "version_page": version,
                        "appareil": rng.choice(["mobile", "ordinateur", "tablette"], nv, p=[0.58, 0.35, 0.07]),
                        "achat": np.where(achat, "oui", "non")})
visites.to_csv(out / "visitesAB.csv", sep=";", decimal=",", index=False, encoding="utf-8-sig")

# ---------- caHebdo.csv ----------
semaines = np.arange(1, 53)
budget = np.round(rng.uniform(1500, 6500, 52), -1)
ca = np.round(18000 + 4.2 * budget + rng.normal(0, 2600, 52), 0)
ca_hebdo = pd.DataFrame({"semaine": [f"2025-S{s:02d}" for s in semaines], "budget_pub_eur": budget.astype(int), "chiffre_affaires_eur": ca.astype(int)})
ca_hebdo.to_csv(out / "caHebdo.csv", sep=";", decimal=",", index=False, encoding="utf-8-sig")
print("ok", commandes.shape, visites.shape, ca_hebdo.shape)
