import zipfile
import pandas as pd

df_redlist = pd.read_csv('/home/wouter/Downloads/Rodlista2015.csv', usecols=['Vitenskapelig navn', "Kategori"])

per_category = {}
for category in df_redlist['Kategori'].unique():
    per_category[category] = df_redlist[df_redlist["Kategori"] == category]['Vitenskapelig navn'].unique().tolist()

columns = ['gbifID', 'scientificName', 'decimalLongitude', 'decimalLatitude']
df_verbatim = pd.read_csv(zipfile.ZipFile('/home/wouter/Downloads/0030840-210914110416597.zip').open('verbatim.txt'), sep='\t',
                              error_bad_lines=False, usecols=columns)

df_filtered = df_verbatim[df_verbatim['scientificName'].isin(per_category['EN'])]

print(len(df_filtered))
print(df_filtered.head())



