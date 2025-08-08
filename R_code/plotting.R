library(ggplot2)
library(legendry)
library(viridis)
library(sf)
library(knitr)
library(ragg)

# Load data
buildings <- st_read("../cairo_data/buildings_utm.gpkg", layer = "buildings")
centroids <- st_read("../cairo_data/centroids_utm.gpkg", layer = "centroids")


# 
file <- knitr::fig_path('in500.png')

# 
agg_png(file, width = 10, height = 5, units = "in", res = 500)

# Plot
base <- ggplot() +
  geom_sf(data = buildings, 
          aes(fill = nearest_dist_m), 
          color = NA) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom",
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  
  ggtitle("Urban Compactness") +
  
  scale_fill_viridis_c(
    name = "Nearest Distance (m)",
    option = "viridis",
    guide = gizmo_histogram(
      hist = buildings$nearest_dist_m,
      hist.args = list(breaks = 30),
      oob = "squish",
      just = 1,
      metric = "counts"
    )
  ) 

base


# 
invisible(dev.off())

# 
knitr::include_graphics(file)
