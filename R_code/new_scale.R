library(ggplot2)
library(sf)
library(legendry)
library(viridis)
library(ggnewscale)
library(dplyr)
library(ragg)
library(ggnewscale)

structured <- buildings %>% filter(type == "structured")
unstructured <- buildings %>% filter(type == "unstructured")
streets <- st_read("data/cairo_edges.gpkg")

unstructured$unstructured_dist <- unstructured$nearest_dist_m
structured$structured_dist <- structured$nearest_dist_m

# 
file <- knitr::fig_path('6.png')

# 
agg_png(file, width = 10, height = 5, units = "in", res = 500)


ggplot() +
  # Streets first (optional)
#  geom_sf(data = streets, color = "gray80", size = 0.3) +
  
  # --- Unstructured buildings ---
  geom_sf(data = unstructured, aes(fill = unstructured_dist), color = NA) +
  scale_fill_viridis_c(
    name = "Unstructured\nNearest Dist. (m)",
    option = "plasma",
    guide = gizmo_histogram(
      hist = unstructured$unstructured_dist,
      hist.args = list(breaks = 30),
      just = 1,
      oob = "squish",
      metric = "counts",
      position = "left"
    )
  ) +
  
  new_scale_fill() +  # << Key line: allows second fill scale
  
  # --- Structured buildings ---
  geom_sf(data = structured, aes(fill = structured_dist), color = NA) +
  scale_fill_viridis_c(
    name = "Structured\nNearest Dist. (m)",
    option = "plasma",
    guide = gizmo_histogram(
      hist = structured$structured_dist,
      hist.args = list(breaks = 30),
      just = 1,
      oob = "squish",
      metric = "counts",
      position = "right"
    )
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
