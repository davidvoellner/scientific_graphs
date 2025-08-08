library(ggplot2)
library(sf)
library(legendry)
library(viridis)
library(ggnewscale)
library(dplyr)
library(ragg)
library(ggnewscale)

# Load data
buildings <- st_read("../cairo_data/buildings_utm.gpkg", layer = "buildings")
structured <- buildings %>% filter(type == "structured")
unstructured <- buildings %>% filter(type == "unstructured")
streets <- st_read("data/cairo_edges.gpkg")

# 
file <- knitr::fig_path('9.png')

# 
agg_png(file, width = 10, height = 5, units = "in", res = 500)


ggplot() +
  # Streets
  geom_sf(data = streets, color = "gray80", size = 0.3) +
  
  # Buildings
  geom_sf(data = buildings, aes(fill = nearest_dist_m), color = NA) +
  
  scale_fill_viridis_c(
    name = "Distance to nearest neighbor (m)",
    option = "viridis",
    guide = gizmo_histogram(
        hist = buildings$nearest_dist_m,
        hist.args = list(breaks = 100),
        just = 1,
        oob = "squish",
        metric = "counts",
        position = "bottom"
        ),
      
    ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom",
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  ggtitle("Urban Compactness by Structure Type")

# 
invisible(dev.off())
