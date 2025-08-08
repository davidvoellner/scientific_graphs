library(sf)
library(ggplot2)
library(dplyr)
library(patchwork)

################
# aim: map in the middle, histograms as "legend" on the right side
# legendry had issues with png device
# I had issues with newscale showing two legendry scales at the same time
# --> manual patchwork alignment of different plots (not as nifty, but still does the job)

# Load spatial data
buildings <- st_read("../cairo_data/buildings_utm.gpkg", layer = "buildings")   #not included in repo
streets <- st_read("data/cairo_edges.gpkg")                #needs to be processed first in "Jupyter_Notebooks/osm_data.ipynb"
nodes <- st_read("data/nodes_with_betweenness.gpkg")

# Filter structured / unstructured
structured <- buildings %>% filter(type == "structured")
unstructured <- buildings %>% filter(type == "unstructured")

unstructured$unstructured_dist <- unstructured$nearest_dist_m
structured$structured_dist <- structured$nearest_dist_m

# Axis limits for consistent axis
all_dists <- buildings$nearest_dist_m
x_limits <- range(all_dists, na.rm = TRUE)

# Compute max density for histogram legend
max_density <- max(
  ggplot_build(
    ggplot(structured, aes(x = nearest_dist_m, y = ..density..)) +
      geom_histogram(binwidth = 1)
  )$data[[1]]$density,
  ggplot_build(
    ggplot(unstructured, aes(x = nearest_dist_m, y = ..density..)) +
      geom_histogram(binwidth = 1)
  )$data[[1]]$density
)

# Map plot
map_plot <- ggplot() +
  # Streets
  geom_sf(data = streets, color = "grey70", size = 0.1) +
  # Nodes
  geom_sf(data = nodes, aes(color = betweenness), size = 1.2) +
  # Buildings
  geom_sf(data = buildings, aes(fill = nearest_dist_m), color = NA) +
  # Building color scale
  scale_fill_viridis_c(
    name = NULL, 
    option = "viridis", 
    guide = "none"
    ) +
  # Node color scale
  scale_color_gradientn(
    name = "Betweenness Centrality", 
    colors = c("#32b1ff", "#fcf683", "#fc694c", "#fa4d5c")
    ) +
  # Remove all ticks and so on
  theme_void() +
  
  ggtitle("Urban Compactness and Betweenness Centrality") + 
  # Show only relevant content
  theme(
    plot.title = element_text(hjust = 0.5, size = 20),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "bottom",
    legend.key.width = unit(4, "cm"),
    legend.key.height = unit(0.5, "cm"),
    legend.title.position = "top",
    legend.title = element_text(hjust = 0.5)
    )

#map_plot

# Structured histogram (right side)
hist_structured <- ggplot(structured, aes(x = nearest_dist_m, y = ..density..)) +
  geom_histogram(aes(fill = ..x..), binwidth = 1, color = NA) +
  scale_fill_viridis_c(option = "D", guide = "none") +
  xlim(x_limits) +
  ylim(0, max_density) +
  theme_void() +
  coord_flip() +
  labs(
    subtitle = "Unstructured") + 
  theme(
    plot.subtitle = element_text(hjust = 0.5),
    axis.title = element_blank(),
    axis.text.y = element_text(color = "black"),
    panel.grid = element_blank()
  )

#hist_structured

# Unstructured histogram (left side, mirrored)
hist_unstructured <- ggplot(unstructured, aes(x = nearest_dist_m, y = ..density..)) +
  geom_histogram(aes(fill = ..x..), binwidth = 1, color = NA) +
  scale_fill_viridis_c(option = "D", guide = "none") +
  xlim(x_limits) +
  scale_y_reverse(limits = c(max_density, 0)) +
  theme_void() +
  coord_flip() +
  labs(
    subtitle = "Unstructured") + 
  theme(
    plot.subtitle = element_text(hjust = 0.5),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

#hist_unstructured

caption_plot <- ggplot() +
  theme_void() +
  labs(
    subtitle = "Urban compactness as distance to nearest building (m)",
    caption = "Datasource: OSM data\nMap author: David Voellner") +
  theme(
    plot.subtitle = element_text(hjust = 0.5),
    plot.caption = element_text(size = 10)
  )

#caption_plot


#############################
layout <- c(
  area(t = 1, l = 1, b = 4, r = 6),  # map plot
  area(t = 2, l = 7, b = 3, r = 7),  # unstructured histogram
  area(t = 2, l = 8, b = 3, r = 8),  # structured histogram
  area(t = 4, l = 7, b = 4, r = 8)   # caption Plot
)

final_plot <- map_plot + hist_unstructured + hist_structured + caption_plot +
  plot_layout(design = layout)

final_plot
