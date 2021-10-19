##Script to run spatial model + data visualizations
library(ggplot2)
library(sf)
library(sp)
library(plyr)
library(dplyr) 
library(ggmap) 
library(maps)
library(PointedSDMs)
library(inlabruSDMs)
library(spatstat)
library(maptools)
library(INLA)
library(rgeos)
library(fields)
library(viridis)

##Read in PO data

##Read in PA data

##Read in habitat + climate data

##Get map of Norway:
 #Correct projection?
Projection <- CRS("+proj=longlat +ellps=WGS84")

  #Norway
norwayfill <- map("world", "norway", fill=TRUE, plot=FALSE, 
                  ylim=c(58,72), xlim=c(4,32))
IDs <- sapply(strsplit(norwayfill$names, ":"), function(x) x[1])
norway.poly <- map2SpatialPolygons(norwayfill, IDs = IDs, 
                                   proj4string = Projection)

#Meshpars <- list(cutoff=0.08, max.edge=c(0.6, 3), offset=c(1,1))
Meshpars <- list(cutoff=0.08, max.edge=c(1, 3), offset=c(1,1))


Spatial_data <- organize_data(..., poresp,paresp,trialname,coords, proj = Projection,
                              speciesname, meshpars = Meshpars, boundary = norway.poly)

Spatial_model <- bru_sdm(spatial_data, spatialcovariates, specieseffects = TRUE,
                         options = list(control.inla = list(int.strategy = 'eb')))





