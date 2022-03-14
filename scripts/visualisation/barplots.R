############ This script draws the barplots illustrating the distribution of cells in the different categories of lat sd ##########

## import our friend ggplot ------------------------------------------------------------------
library(ggplot2)

## Read sd results and get rid of longitude (odd indexes) ------------------------------------
sds <- readRDS("./data/standard_deviation_4mdls_nothresh.RDS")
sds <- sds[-MAX, -c(1:2, which(seq(from = 3, to = ncol(sds)+1, by = 1) %%2 != 0))] #MAX comes from the "cell_to_drop.R" script


## Df for the barplot ------------------------------------------------------------------------

final_df <- data.frame(TIME = rep(x = 0, 5),
                       CAT = c("A: 0-5°", "B: 5-10°", "C: 10-20°", "D: 20-30°", "E: >30°"),
                       COUNTS = c(29500, 0, 0, 0, 0))

for(t in seq(from = 10, to = 540, by = 10)){
  final_df <- rbind(final_df,
                    data.frame(TIME = rep(x = t, 5),
                               CAT = c("A: 0-5°", "B: 5-10°", "C: 10-20°", "D: 20-30°", "E: >30°"),  #the five categories we're considering
                               COUNTS = c(
                                 length(which(sds[, t/10] < 5)),
                                 length(which((sds[, t/10] < 10) & (sds[, t/10] >= 5))), #translating these categories in terms of logical condition
                                 length(which((sds[, t/10] < 20) & (sds[, t/10] >= 10))),
                                 length(which((sds[, t/10] < 30) & (sds[, t/10] >= 20))),
                                 length(which(sds[, t/10] >= 30))
                               )
                    ))
}


## Plotting -----------------------------------------------------------------------------------

  #raw counts
barplt <- ggplot(data = final_df, aes(fill = CAT, x = TIME, y = COUNTS)) +
  geom_bar(position = "stack", #display counts
           stat = "identity") +
  scale_fill_manual(values = c('#f7fcb9','#addd8e','#41ab5d','#006837','#004529')) +
 # scale_fill_viridis(discrete = T) +
  scale_x_reverse() +
  theme(axis.title.x = element_text(size = 18),
        axis.title.y = element_text(size = 18),
        axis.text = element_text(size = 15),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 15),
        legend.key.size = unit(1, "cm"),
        panel.grid.major = element_blank(), # Remove panel grid lines
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), # Remove panel background
        panel.border = element_rect(colour = "black", fill = NA, size = 1) #frame the plot
        ) +
  labs(x = "Time (Ma)", y = "Cell count", fill = "Category") +
  geom_vline(xintercept = 200, col = "red", linetype = "dashed", lwd = 1) +
  geom_vline(xintercept = 410, col = "red", linetype = "dashed", lwd = 1) +
  annotate(geom = "text", x = 205, y = 28000, label = "Seton Time Limit", angle = 90, size = 3, fontface = "italic", col = "red") +
  annotate(geom = "text", x = 415, y = 28000, label = "Matthews Time Limit", angle = 90, size = 3, fontface = "italic", col = "red")

print(barplt)

ggsave(filename = "./figures/barplots/barplot_counts.pdf", plot = barplt, width = 14, height = 7, units = "in") #save as pdf
ggsave(filename = "./figures/barplots/barplot_counts.png", plot = barplt, width = 14, height = 7, units = "in") #and png

