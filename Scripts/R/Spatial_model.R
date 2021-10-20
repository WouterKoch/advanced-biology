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

##Get map of Norway:
 #Correct projection?
#Projection <- CRS("+proj=longlat +ellps=WGS84")
Projection <- CRS('+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs')
  #Norway
norwayfill <- map("world", "norway", fill=TRUE, plot=FALSE, 
                  ylim=c(58,72), xlim=c(4,32))
IDs <- sapply(strsplit(norwayfill$names, ":"), function(x) x[1])
norway.poly <- map2SpatialPolygons(norwayfill, IDs = IDs, 
                                   proj4string = Projection)

##Read in PA data
setwd('/Users/philism/Downloads/')

##Read in all data not Oslo
norge_data <- read.csv('VU.PA.data.Norge.txt', sep = ' ')

##Clean Oslo data to remove any odd coordinates
olso_data <- read.csv('VU.PA.data.Olso.txt', sep = ' ')
olso_data <- olso_data[!(olso_data$decimalLongitude == 0),] 
oslo_data <- olso_data[!(olso_data$decimalLatitude == 0),]

##Combine Oslo + norge_data

PA_data <- rbind(norge_data, olso_data)
##View most abundant species:: subset top 3

abundant <- PA_data %>% group_by(scientificName) %>% count() %>% arrange(desc(n)) %>% data.frame
abundant <- abundant[1:3,1]

PA_data <- PA_data[PA_data$scientificName%in%abundant,]

PA_data <- sp::SpatialPointsDataFrame(coords = data.frame(PA_data$decimalLongitude, PA_data$decimalLatitude),
                                      data = data.frame(scientificName = PA_data$scientificName, individualCount = PA_data$individualCount),
                                      proj4string = Projection)

ggplot() + gg(norway.poly) + gg(PA_data)

##Make grid 
grid <- makegrid(norway.poly, cellsize = 0.25, pretty = FALSE)
grid <- SpatialPoints(grid, proj4string = Projection)
ggplot()  + gg(grid) + gg(PA_data) + gg(norway.poly) 

spgrdWithin <- SpatialPixels(grid[norway.poly,])
spgrdWithin <- as(spgrdWithin, "SpatialPolygons")
ggplot() + gg(spgrdWithin)

##Fit closest points to grid points
PA_data_frame <- as.data.frame(PA_data)
closest <- RANN::nn2(data = grid@coords, query = PA_data_frame[,3:4], k = 1)
grid$ID <- seq(nrow(grid@coords))

closest_ind <- as.data.frame(closest) %>%
  dplyr::rename(ID = nn.idx)

closest_ind$scientificName <- PA_data_frame$scientificName
closest_ind$individualCount <- PA_data_frame$individualCount

joined <- dplyr::inner_join(closest_ind,as.data.frame(grid), by = 'ID') 

grid_data <- sp::SpatialPointsDataFrame(coords = data.frame(joined$x1, joined$x2),
                                        data = data.frame(scientificName = joined$scientificName, individualCount = joined$individualCount),
                                        proj4string = Projection)
colnames(grid_data@coords) <- c('x','y')

##Remove all points in the sea???

grid_data <- grid_data[!is.na(over(grid_data, norway.poly)),]
ggplot() + gg(norway.poly) + gg(grid_data, col = 'red') #+ gg(grid)

species <- unique(grid_data$scientificName)

unique_grid <- as.data.frame(grid_data) %>%
  group_by(x,y) %>%
  slice(1) %>%
  select(x,y) %>%
  data.frame()

grid_index <- list()
for (i in 1:nrow(unique_grid)) {
  
  x <- unique_grid[i,1]
  y <- unique_grid[i,2]
  
  present <- grid_data[grid_data@coords[,1] == x & grid_data@coords[,2] == y,]
  
  not_in <- species[!species%in%present$scientificName]
  
  if (!identical(not_in, character(0))) {

  ind <- data.frame(scientificName = not_in, individualCount = 0)
  
  ind_coords <- data.frame(x,y) %>% slice(rep(1:n(), each = length(not_in)))
  
  absent <- sp::SpatialPointsDataFrame(coords = ind_coords, data = ind,
                                                proj4string = Projection)
  
  grid_index[[i]] <- rbind.SpatialPointsDataFrame(present, absent)
  
  }
  else grid_index[[i]] <- present
  
}

PA_data <- do.call(rbind.SpatialPointsDataFrame, grid_index)
colnames(PA_data@coords) <- c('Longitude','Latitude')
ggplot() + gg(PA_data, aes(col = factor(individualCount))) +
  facet_grid(~scientificName) +
  gg(norway.poly) +
  gg(spgrdWithin) +
  coord_equal() +
  scale_fill_continuous(guide = guide_legend()) +
  scale_color_manual(labels = c('Absent', "Present"), values = c("#d11141", "#00aedb")) +
  labs(x = 'Longitude', y = 'Latitude', col = 'Grid Observation') +
  ggtitle('Present absence data') +
  theme_classic() +
  theme(legend.position="bottom",
        plot.title = element_text(hjust = 0.5))

ggsave('PA_plot.png',
       width = 40,
       height = 40,
       units = 'cm')

##Read in PO data

PO_data <- read.csv('Presence only - VU (selected species).csv')

PO_data <- sp::SpatialPointsDataFrame(coords = data.frame(PO_data$decimalLongitude, PO_data$decimalLatitude),
                                      data = data.frame(scientificName = PO_data$scientificName),
                                      proj4string = Projection)
##Remove points in sea
PO_data <- PO_data[!is.na(over(PO_data, norway.poly)),]
colnames(PO_data@coords) <- c('Longitude','Latitude')

ggplot() +
  gg(norway.poly) +
  gg(PO_data, aes(col = scientificName)) +
  coord_equal() +
  scale_color_manual(values = c("#d11141", "#00aedb",'#00b159')) + 
  labs(x = 'Longitude', y = 'Latitude', col = 'Scientific name') +
  ggtitle('Present only data') +
  theme_classic() +
  theme(legend.position="bottom",
        plot.title = element_text(hjust = 0.5))

ggsave('PO_plot.png',
       width = 40,
       height = 40,
       units = 'cm')
##Read in habitat + climate data


## Model fitting part
#Meshpars <- list(cutoff=0.08, max.edge=c(0.6, 3), offset=c(1,1))
Meshpars <- list(cutoff=0.08, max.edge=c(1, 3), offset=c(1,1))

Spatial_data <- organize_data(PO_data,
                              PA_data, 
                              poresp = 'response',
                              paresp = 'individualCount',
                              coords = c('Longitude','Latitude'),
                              proj = Projection,
                              speciesname = 'scientificName',
                              meshpars = Meshpars,
                              boundary = norway.poly)

##setwd
Spatial_model <- bru_sdm(spatial_data, spatialcovariates, specieseffects = TRUE,
                         options = list(control.inla = list(int.strategy = 'eb')))

saveRDS(Spatial_model, 'Spatial_model.RDS')

projections_lin <- predict(Spatial_model, mesh = Spatial_data@mesh, mask = norway.poly,
                           datasetstopredict = Spatial_model$dataset_names,
                           covariates = NULL, intercept = TRUE, species = TRUE,
                           spatial = TRUE, fun = 'linear', n.samples = 1000)

saveRDS(projections_lin, 'projections_lin.RDS')

projections_exp <- predict(Spatial_model, mesh = Spatial_data@mesh, mask = norway.poly,
                           datasetstopredict = Spatial_model$dataset_names,
                           covariates = NULL, intercept = TRUE, species = TRUE,
                           spatial = TRUE, fun = 'exp', n.samples = 1000)

saveRDS(projections_exp, 'projections_exp.RDS')




