
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

Projection <- CRS("+proj=longlat +ellps=WGS84")
norwayfill <- map("world", "norway", fill=TRUE, plot=FALSE, 
                  ylim=c(58,72), xlim=c(4,32))
IDs <- sapply(strsplit(norwayfill$names, ":"), function(x) x[1])
norway.poly <- map2SpatialPolygons(norwayfill, IDs = IDs, 
                                   proj4string = Projection)

grid <- makegrid(norway.poly, cellsize = 1)
grid <- SpatialPoints(grid, proj4string = Projection)
ggplot()  + gg(grid) + gg(norway.poly)

spgrdWithin <- SpatialPixels(grid[norway.poly,])
spgrdWithin <- as(spgrdWithin, "SpatialPolygons")
ggplot() + gg(spgrdWithin)

Meshpars <- list(cutoff=0.08, max.edge=c(0.6, 3), offset=c(1,1))
#Meshpars <- list(cutoff=0.08, max.edge=c(1, 3), offset=c(1,1))

Mesh <- MakeSpatialRegion(data=NULL, bdry=norway.poly, meshpars=Meshpars,
                          proj = Projection)




