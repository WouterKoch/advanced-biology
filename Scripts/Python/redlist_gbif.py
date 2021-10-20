import zipfile
import pandas as pd
import urllib.request
import os.path
import matplotlib.pyplot as plt
import seaborn as sns

# Data directory is assumed to be set to be the working dir

gbif_url = "https://api.gbif.org/v1/occurrence/download/request/0030840-210914110416597.zip"
redlist_url = "https://artsdatabanken.no/Rodliste2015/sok/Eksport?kategori=re%2ccr%2cen%2cvu%2cnt%2cdd&vurderings%u00e5r=2015&vurderingscontext=n&taxonrank=species"
max_uncertainty = 1000
species_subset = ["Fraxinus excelsior", "Ulmus glabra", "Arnica montana"]
sns.set_style("whitegrid")

# Download the GBIF (presence only) data
if not os.path.exists('Presence_only.zip'):
    urllib.request.urlretrieve(gbif_url, 'Presence_only.zip')

if not os.path.exists('Rodlista2015.csv'):
    urllib.request.urlretrieve(redlist_url, 'Rodlista2015.csv')

df_redlist = pd.read_csv('Rodlista2015.csv', usecols=['Vitenskapelig navn', "Kategori"])

per_category = {}
for category in df_redlist['Kategori'].unique():
    per_category[category] = df_redlist[df_redlist["Kategori"] == category]['Vitenskapelig navn'].unique().tolist()

columns = ['scientificName', 'decimalLongitude', 'decimalLatitude', 'coordinateUncertaintyInMeters']
df_verbatim = pd.read_csv(zipfile.ZipFile('Presence_only.zip').open('verbatim.txt'), sep='\t',
                          error_bad_lines=False, usecols=columns)

for cat in ['VU', 'EN', 'CR']:
    df_filtered = df_verbatim[
        (df_verbatim['scientificName'].isin(per_category[cat])) & (
                df_verbatim['coordinateUncertaintyInMeters'] < max_uncertainty)]
    df_filtered.to_csv("Presence only - " + cat + ".csv", index=False)
    df_filtered_species = df_filtered[
        (df_filtered['scientificName'].isin(species_subset))]
    df_filtered_species.to_csv("Presence only - " + cat + " (selected species).csv", index=False)

    fig, axes = plt.subplots(1, 2, figsize=(12, 8))
    fig.suptitle(cat)

    ax = sns.scatterplot(ax=axes[0], data=df_filtered, x='decimalLongitude', y='decimalLatitude')
    ax.legend([], [], frameon=False)
    ax.set(ylim=(56, 72), xlim=(4, 34))
    ax.set_title("All occurrences")

    ax = sns.scatterplot(ax=axes[1], data=df_filtered_species, x='decimalLongitude', y='decimalLatitude', hue='scientificName')
    ax.legend([], [], frameon=False)
    ax.set(ylim=(56, 72), xlim=(4, 34))
    ax.set_title("Selected species")

    plt.savefig(os.path.join(cat + '.png'), dpi=300)
    plt.close()
