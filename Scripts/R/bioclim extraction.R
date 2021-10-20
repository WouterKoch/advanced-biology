#### BioClim data

.libPaths()
.libPaths("C:/Users/runesora/Dropbox/R Script!/Library")

library(raster)
library(sp)
library(rgeoboundaries)

setwd("C:/Users/runesora/Dropbox/ppppp/BI8091")

bioclimS <- getData("worldclim",var="bio",res=0.5, lon=5, lat=60)
bioclimN <- getData("worldclim",var="bio",res=0.5, lon=5, lat=70)

#summary(bioclim)

bioclimS <- bioclimS[[c(3,4,10,12)]]
names(bioclimS) <- c("Isothermality", "Temperature Seasonality","Mean Ta of warmest quarter", "Prec")

bioclimN <- bioclimN[[c(3,4,10,12)]]
names(bioclimN) <- c("Isothermality", "Temperature seasonality","Mean Ta of warmest quarter", "Prec")


#### Norway #####
norway0 <- getData('GADM', country='NOR', level=0)

par(mfrow(2,1))
plot(norway0, main="Adm. Boundaries Norway Level 0")
plot(norway1, main="Adm. Boundaries Austria Level 1")

# merge
r1 <- crop(bioclimN, bbox(norway0))
r2 <- crop(bioclimS, bbox(norway0))

rasterm <- raster::merge(r1,r2)

plot(rasterm)
plot(norway0, add=T)

rasterm
saveRDS(rasterm, 'raster_covariates.RDS')
# upscale to 0.025 ######

r_up_0.025 <- aggregate(rasterm, fact = 0.025/res(rasterm)) # aggregate output
res(r_up_0.025)

plot(r_up_0.025)

r_up_0.025

