library(dplyr)

## 2.1. Download the PA data from GBIF.

download_url_trd <- "https://gbif.vm.ntnu.no/ipt/archive.do?r=vascularplantfieldnotes"
if(!file.exists("C:/advanced-biology/Scripts/Data/gbif_PA_trd.zip")) {
  download.file(url=download_url_trd, destfile="C:/advanced-biology/Scripts/Data/gbif_PA_trd.zip", mode = "wb")
}

download_url_osl <- "https://ipt.gbif.no/archive.do?r=o_vxl"
if(!file.exists("Data/gbif_PA_osl.zip")) {
  download.file(url=download_url_osl, destfile="Data/gbif_PA_osl.zip", mode = "wb")
}

## 2.2. Read into R and prepare for filtering

gbif_data_trd <- read.table(unzip(zipfile = "Data/gbif_PA_trd.zip", files="occurrence.txt"), header=T, sep="\t", quote="", fill=FALSE) %>%
  select(c(eventID, decimalLatitude, decimalLongitude,
           coordinateUncertaintyInMeters, scientificName,
           individualCount)) 


gbif_data_oslo <- read.table(unzip(zipfile = "Data/gbif_PA_osl.zip", files="occurrence.txt"), header=T, sep="\t", quote="", fill=TRUE) %>%
  subset(., !is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  subset(., year != 0) %>%
  mutate(eventID = paste(day, month, year, decimalLatitude, decimalLongitude, sep = "_")) %>%
  mutate(count = 1) %>%
  group_by(eventID, scientificName) %>%
  mutate(count = sum(count)) %>%
  mutate(individualCount = ifelse(count >= 1, 1, 0)) %>%
  select(c(decimalLatitude, decimalLongitude, 
           individualCount, scientificName, eventID, coordinateUncertaintyInMeters)) %>%
  data.frame()

###  2.3. Filter the PA data from the Red List Data species list (made in step 1) --- 
## Will result in three files. (want visit numbers too, column per variable).


## filter data based on redlist

# read redlist data
redlist <- read.csv2("Data/Rodlista2015_Artsdatabanken_format.csv")[c("Vitenskapelig.navn", "Kategori")]

# select species in PA file also present in redlist
# note: species names in PA file does not seem to be formatted in a consequent way, 
# names formatted differently than the redlist will not be filtered

CR.PA.data.trd <- gbif_data_trd %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("CR")])
EN.PA.data.trd <- gbif_data_trd %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("EN", "ENº")])
VU.PA.data.trd <- gbif_data_trd %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("VU", "VUº")])

CR.PA.data.osl <- gbif_data_oslo %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("CR")])
EN.PA.data.osl <- gbif_data_oslo %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("EN", "ENº")])
VU.PA.data.osl <- gbif_data_oslo %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("VU", "VUº")])

CR.PA.data <- rbind(CR.PA.data.trd, CR.PA.data.osl)
EN.PA.data <- rbind(EN.PA.data.trd, EN.PA.data.osl)
VU.PA.data <- rbind(VU.PA.data.trd, VU.PA.data.osl)

write.table(CR.PA.data, file = "Data/CR.PA.data.txt")
write.table(EN.PA.data, file = "Data/EN.PA.data.txt")
write.table(VU.PA.data, file = "Data/VU.PA.data.txt")


## 2.4. Rescale & rasterize these three files (will have dataframe with lat and long which gives back centroid points of grid squares, we can define the size here). 
## 2.5. Infer absences per grid.
## 2.6. End: Three separate files, turn into SP objects (?)
## 2.7. Plot presence/absence data on a map. 
