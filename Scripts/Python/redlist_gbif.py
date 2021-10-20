import zipfile
import pandas as pd
import urllib.request
import os.path
import matplotlib.pyplot as plt
import seaborn as sns

'''
STEP 1: Species Observations data acquire, filter, combine.
    1.1. Download the PO data from GBIF. 
    1.2. Download the NBIC (Red List Norway) data.
    1.3. Read each file independently into R, clean.
    Drop every column except for:
        Red List: Species Name & Red List status
        PO: Coordinates, coordinate precision, species names
    
    1.4. Filter the PO data from the Red List Data: For every Red List status of interest, get a unique list of species. Use this list to filter for species in PO data.    
    1.5. Filter for coordinate precision lower than predetermined precision goes here. 
    1.6. Turn into SP object (can be done on import from CSV by PM)
    1.7. Collate into unique totals per species per grid cell (three separate files still). (Gridding will be done later as not to throw away resolution now)
    1.8. Plot all presence only data on a map. 

'''

# NOTE: Data directory is assumed to be set to be the working dir

gbif_url = "https://api.gbif.org/v1/occurrence/download/request/0030840-210914110416597.zip"
redlist_url = "https://artsdatabanken.no/Rodliste2015/sok/Eksport?kategori=re%2ccr%2cen%2cvu%2cnt%2cdd&vurderings%u00e5r=2015&vurderingscontext=n&taxonrank=species"
max_uncertainty = 1000
species_subset = ["Fraxinus excelsior", "Ulmus glabra", "Arnica montana"]
sns.set_style("whitegrid")

# 1.1. Download the PO data from GBIF.
if not os.path.exists('Presence_only.zip'):
    urllib.request.urlretrieve(gbif_url, 'Presence_only.zip')

# 1.2. Download the NBIC (Red List Norway) data.
if not os.path.exists('Rodlista2015.csv'):
    urllib.request.urlretrieve(redlist_url, 'Rodlista2015.csv')

# 1.3. Read each file independently, clean.
# Drop every column except for:
#     Red List: Species Name & Red List status
#     PO: Coordinates, coordinate precision, species names

columns = ['Vitenskapelig navn', "Kategori"]
df_redlist = pd.read_csv('Rodlista2015.csv', usecols=columns)

columns = ['scientificName', 'decimalLongitude', 'decimalLatitude', 'coordinateUncertaintyInMeters']
df_verbatim = pd.read_csv(zipfile.ZipFile('Presence_only.zip').open('verbatim.txt'), sep='\t',
                          error_bad_lines=False, usecols=columns)

per_category = {}
for category in df_redlist['Kategori'].unique():
    per_category[category] = df_redlist[df_redlist["Kategori"] == category]['Vitenskapelig navn'].unique().tolist()

# 1.4. Filter the PO data from the Red List Data: For every Red List status of interest,
#   get a unique list of species. Use this list to filter for species in PO data.
# 1.5. Filter for coordinate precision lower than predetermined precision goes here.
# 1.8. Plot all presence only data on a map.

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

    ax = sns.scatterplot(ax=axes[1], data=df_filtered_species, x='decimalLongitude', y='decimalLatitude',
                         hue='scientificName')
    ax.legend([], [], frameon=False)
    ax.set(ylim=(56, 72), xlim=(4, 34))
    ax.set_title("Selected species")

    plt.savefig(os.path.join(cat + '.png'), dpi=300)
    plt.close()
