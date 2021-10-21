### This scripts downloads and prepares Presence Absence Data from GBIF to use as input in 
### SDMs

### Description of each step -------------------
## 2.1. Download the PA data from GBIF.
## 2.2. Read into R and prepare for filtering
## 2.3. Filter the PA data from the Red List Data species list (made in step 1) 
## Will result in three files. (want visit numbers too, column per variable).


## 2.1. Download the PA data from GBIF. ---------------

# Download data from NTNU University Museum
download_url_trd <- "https://gbif.vm.ntnu.no/ipt/archive.do?r=vascularplantfieldnotes"
if(!file.exists("Data/gbif_PA_trd.zip")) {
  download.file(url=download_url_trd, destfile="Data/gbif_PA_trd.zip", mode = "wb")
}

# Download data from University of Oslo
download_url_osl <- "https://ipt.gbif.no/archive.do?r=o_vxl"
if(!file.exists("Data/gbif_PA_osl.zip")) {
  download.file(url=download_url_osl, destfile="Data/gbif_PA_osl.zip", mode = "wb")
}

## 2.2. Read into R and prepare for filtering ----------

# Read NTNU data and select relevant columns
gbif_data_trd <- read.table(unzip(zipfile = "Data/gbif_PA_trd.zip", files="occurrence.txt"), header=T, sep="\t", quote="", fill=FALSE) %>%
  select(c(eventID, decimalLatitude, decimalLongitude,
           coordinateUncertaintyInMeters, scientificName,
           individualCount)) 

# Read data from UiO
gbif_data_oslo <- read.table(unzip(zipfile = "Data/gbif_PA_osl.zip", files="occurrence.txt"), header=T, sep="\t", quote="", fill=TRUE) %>%
  # remove missing coordinates
  subset(., !is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  # remove data with missing information on year
  subset(., year != 0) %>%
  # make unique id for each event
  mutate(eventID = paste(day, month, year, decimalLatitude, decimalLongitude, sep = "_")) %>%
  # make column with information about presence for each event
  mutate(count = 1) %>%
  group_by(eventID, scientificName) %>%
  mutate(count = sum(count)) %>%
  mutate(individualCount = ifelse(count >= 1, 1, 0)) %>%
  # select relevant columns
  select(c(decimalLatitude, decimalLongitude, 
           individualCount, scientificName, eventID, coordinateUncertaintyInMeters)) %>%
  data.frame()


## 2.3. Filter the PA data from the Red List Data species list (made in step 1) ----- 
## Will result in three files. (want visit numbers too, column per variable).

# download and read redlist data
download_url_redlist <- "https://artsdatabanken.no/Rodliste2015/sok/Eksport?kategori=re%2ccr%2cen%2cvu%2cnt%2cdd&vurderings%u00e5r=2015&vurderingscontext=n&taxonrank=species"
if(!file.exists("Data/Rodlista2015_Artsdatabanken_format.csv")) {
  download.file(url=download_url_redlist, destfile="Data/Rodlista2015_Artsdatabanken_format.csv", mode = "wb")
}

redlist <- read.csv2("Data/Rodlista2015_Artsdatabanken_format.csv", na.strings = c("", NA), fileEncoding="UTF-16LE")[c("Vitenskapelig.navn", "Kategori")]

# select species in PA files also present in redlist
# note: species names in PA file does not seem to be formatted in a consequent way, 
# names formatted differently than the redlist will not be filtered

# one data frame for each relevant redlist category
CR.PA.data.trd <- gbif_data_trd %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("CR")])
EN.PA.data.trd <- gbif_data_trd %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("EN", "ENº")])
VU.PA.data.trd <- gbif_data_trd %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("VU", "VUº")])

CR.PA.data.osl <- gbif_data_oslo %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("CR")])
EN.PA.data.osl <- gbif_data_oslo %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("EN", "ENº")])
VU.PA.data.osl <- gbif_data_oslo %>% subset(scientificName %in% redlist$Vitenskapelig.navn[redlist$Kategori %in% c("VU", "VUº")])

# combine NTNU and UiO data sets
CR.PA.data <- rbind(CR.PA.data.trd, CR.PA.data.osl)
EN.PA.data <- rbind(EN.PA.data.trd, EN.PA.data.osl)
VU.PA.data <- rbind(VU.PA.data.trd, VU.PA.data.osl)

# write files for SDMs
write.table(CR.PA.data, file = "Data/CR.PA.data.txt")
write.table(EN.PA.data, file = "Data/EN.PA.data.txt")
write.table(VU.PA.data, file = "Data/VU.PA.data.txt")


