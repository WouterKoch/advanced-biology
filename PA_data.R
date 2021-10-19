library(dplyr)

## 2.1. Download the PA data from GBIF.
 ### get some help with this
## 2.2. Read into R

destfile <- "Data/gbif_PA.zip"
gbif_occurrence <- read.table(unzip(zipfile=destfile, files="occurrence.txt"), header=T, sep="\t", quote="", fill=FALSE)
gbif_event <- read.table(unzip(destfile,files="event.txt"), header=T, sep="\t", quote="", fill=FALSE)



## 2.3. Filter the PA data from the Red List Data species list (made in step 1). 
## Will result in three files. (want visit numbers too, column per variable).
data <- select(gbif_occurrence, c(eventID, decimalLatitude, decimalLongitude,
                                     coordinateUncertaintyInMeters, scientificName,
                                     individualCount)) 


head(data)

## select data based on redlist

# read redlist data
redlist <- read.csv2("Data/Rodlista2015_Artsdatabanken_format.csv")[c("Vitenskapelig.navn", "Kategori")]

# select species in PA file also present in redlist
# note: species names in PA file does not seem to be formatted in a consequent way, 
# names formatted differently than the redlist will not be filtered

CR.PA.data <- data %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("CR")])
EN.PA.data <- data %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("EN", "ENº")])
VU.PA.data <- data %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("VU", "VUº")])

write.table(CR.PA.data, file = "data/CR.PA.data.txt")
write.table(EN.PA.data, file = "data/EN.PA.data.txt")
write.table(VU.PA.data, file = "data/VU.PA.data.txt")

#VU.PA.data <- data %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("VU", "VUº")]) %>%
#  group_by(eventID, scientificName) %>%
#  mutate(occurrences = sum(individualCount)) %>%
#  data.frame()






## 2.4. Rescale & rasterize these three files (will have dataframe with lat and long which gives back centroid points of grid squares, we can define the size here). 
## 2.5. Infer absences per grid.
## 2.6. End: Three separate files, turn into SP objects (?)
## 2.7. Plot presence/absence data on a map. 
