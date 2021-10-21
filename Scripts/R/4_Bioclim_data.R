#### BioClim data


library(raster)
library(sp)
library(ggplot2)
library(ggpubr)
library(here)


bioclimS <- getData("worldclim", var = "bio", res = 0.5, lon = 5, lat = 60, path = here("Data"))
bioclimN <- getData("worldclim", var = "bio", res = 0.5, lon = 5, lat = 70, path = here("Data"))

#summary(bioclim)

bioclimS <- bioclimS[[c(3, 4, 10, 12)]]
names(bioclimS) <- c("Isothermality", "Temperature Seasonality", "Mean Ta of warmest quarter", "Prec")

bioclimN <- bioclimN[[c(3, 4, 10, 12)]]
names(bioclimN) <- c("Isothermality", "Temperature seasonality", "Mean Ta of warmest quarter", "Prec")


#### Norway #####
norway0 <- getData('GADM', country = 'NOR', level = 0)


# merge
r1 <- crop(bioclimN, bbox(norway0))
r2 <- crop(bioclimS, bbox(norway0))

rasterm <- raster::merge(r1, r2)

rasterm = mask(rasterm, norway0)

rasterm$layer.2 <- rasterm$layer.2 / 100 / 10
rasterm$layer.3 <- rasterm$layer.3 / 10

plot(rasterm)
plot(norway0, add = T)

rasterm
saveRDS(rasterm, 'raster_covariates.RDS')
# upscale to 0.025 ######

r_up_0.025 <- aggregate(rasterm, fact = 0.025 / res(rasterm)) # aggregate output
res(r_up_0.025)

plot(r_up_0.025)

r_up_0.025

# ggplot
#isothermality
isothermality <- as.data.frame(r_up_0.025$layer.1, xy = TRUE, na.rm = TRUE)

iso <- ggplot(data = isothermality, aes(x = x, y = y)) +
  geom_raster(aes(fill = layer.1)) +
  labs(title = "Isothermality") +
  xlab("Longitude") +
  ylab("Latitude") +
  scale_fill_gradientn(name = "Isothermality",
                       colours = c("#0094D1", "#68C1E6", "#FEED99", "#AF3301"),
                       breaks = c(20, 24, 28, 32)) +
  theme_classic()

# temperature seasonality
Tseasonality <- as.data.frame(r_up_0.025$layer.2, xy = TRUE, na.rm = TRUE)

Tseas <- ggplot(data = Tseasonality, aes(x = x, y = y)) +
  geom_raster(aes(fill = layer.2)) +
  labs(title = "Temperature") +
  xlab("Longitude") +
  ylab("Latitude") +
  scale_fill_gradientn(name = "Temp",
                       colours = c("#0094D1", "#68C1E6", "#FEED99", "#AF3301")) +
  theme_classic()

# mean Ta of warmest quarter
Tmean <- as.data.frame(r_up_0.025$layer.3, xy = TRUE, na.rm = TRUE)

Tmea <- ggplot(data = Tmean, aes(x = x, y = y)) +
  geom_raster(aes(fill = layer.3)) +
  labs(title = "Mean temperature of warmest quarter") +
  xlab("Longitude") +
  ylab("Latitude") +
  scale_fill_gradientn(name = "temp",
                       colours = c("#0094D1", "#68C1E6", "#FEED99", "#AF3301")) +
  theme_classic()

# converting into dataframe and plotting in ggplot ####
prec <- as.data.frame(r_up_0.025$layer.4, xy = TRUE, na.rm = TRUE)

pre <- ggplot(data = prec,
              aes(x = x, y = y)) +
  geom_raster(aes(fill = layer.4)) +
  labs(title = "Annual precipitation") +
  xlab("Longitude") +
  ylab("Latitude") +
  scale_fill_gradientn(name = "Prec (mm)",
                       colours = c("lightblue3", "steelblue3", "royalblue3", "royalblue4")) +
  theme_classic()

ggarrange(iso, Tseas, Tmea, pre + rremove("x.text"),
          labels = c("A", "B", "C", "D"),
          ncol = 2, nrow = 2)


ggsave("bioclim.png", plot = last_plot(), device = "png", scale = 1, dpi = 600, limitsize = TRUE)
