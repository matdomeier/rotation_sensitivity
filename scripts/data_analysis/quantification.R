############### This script estimates and plots the evolution of the lat sd according to the different ID_weight zones ################

## Import libraries ------------------------------------------------------------------------------------

library(ggplot2)


## Input datasets --------------------------------------------------------------------------------------

SD <- readRDS("./data/standard_deviation_4mdls.RDS") # lat standard deviation across space and time
SD <- SD[-MAX, -c(1:2, which(seq(from = 3, to = ncol(SD)+1, by = 1) %% 2 != 0))]
ID_weight <- readRDS("./data/data_pts_plate_IDs_according_to_the_four_models.RDS") #ID_weight


## Assess and store average SD and IC 95 ---------------------------------------------------------------

IC_95 <- function(std, n){ #function to caculate confidence interval at a 95% confidence level (n big => t_95 = 1.96)
  return(1.96*std/sqrt(n))
}

final <- data.frame(TIME = c(0,0,0,0),
                    AVERAGE_SD = c(0,0,0,0),
                    ID_w = c("Global", "ID_weight = 1", "ID_weight = 2", "ID_weight = 3"),
                    CI_95 = c(0,0,0,0))

index_IDw1 <- which(ID_weight$ID_weight == 1) #as the cells of SD and ID_weight are ordered in the same way, we can directly use these lists
index_IDw2 <- which(ID_weight$ID_weight == 2)
index_IDw3 <- which(ID_weight$ID_weight == 3)


for(t in seq(from = 50, to = 500, by = 50)){
  
  av_glob <- mean(SD[, t/10+2], na.rm = TRUE)
  IC_glob <- IC_95(std = sd(SD[, t/10+2], na.rm = TRUE), 
                   n = length(na.omit(SD[, t/10+2])))
  
  av_1 <- mean(SD[index_IDw1, t/10+2], na.rm = TRUE)
  IC_1 <- IC_95(std = sd(SD[index_IDw1, t/10+2], na.rm = TRUE), 
                   n = length(na.omit(SD[index_IDw1, t/10+2])))
  
  av_2 <- mean(SD[index_IDw2, t/10+2], na.rm = TRUE)
  IC_2 <- IC_95(std = sd(SD[index_IDw2, t/10+2], na.rm = TRUE), 
                n = length(na.omit(SD[index_IDw2, t/10+2])))
  
  av_3 <- mean(SD[index_IDw3, t/10+2], na.rm = TRUE)
  IC_3 <- IC_95(std = sd(SD[index_IDw3, t/10+2], na.rm = TRUE), 
                   n = length(na.omit(SD[index_IDw3, t/10+2])))
  
  final <- rbind(final,
                 final <- data.frame(TIME = -c(t,t,t,t),
                                     AVERAGE_SD = c(av_glob, av_1, av_2, av_3),
                                     ID_w = c("Global", "ID_weight = 1", "ID_weight = 2", "ID_weight = 3"),
                                     CI_95 = c(IC_glob, IC_1, IC_3, IC_3)))
}


## Plot it ----------------------------------------------------------------------------------------------

bplt <- ggplot(data = final, aes(x = TIME, y = AVERAGE_SD, fill = ID_w, width = 35)) +
          geom_bar(stat = "identity", color = "black", position = position_dodge()) +
          geom_errorbar(aes(ymin = AVERAGE_SD - CI_95, ymax = AVERAGE_SD + CI_95),
                        width = 11, 
                        position=position_dodge(35)) +
          theme(axis.title.x = element_text(size = 15),
                axis.title.y = element_text(size = 15),
                axis.text = element_text(size = 12),
                legend.text = element_text(size = 12),
                legend.key.size = unit(0.5, "cm"),
                panel.border = element_blank(), # Remove panel border
                panel.grid.major = element_blank(), # Remove panel grid lines
                panel.grid.minor = element_blank(), 
                panel.background = element_blank(), # Remove panel background
                axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
          ) +
          labs(x = "Time (Myr BP)", y = "Average SD (°)", fill = "") +
          geom_vline(xintercept = -200, col = "black") +
          geom_vline(xintercept = -410, col = "black") +
          scale_fill_manual(values = c("black", "grey75", "yellow", "red"))


ggsave(filename = "./figures/SD_IDw_barplot.png", plot = bplt)


## Student test -----------------------------------------------------------------------------------------

#we are going to compute t_tests testing the differences globalxID_weight1 and GlobalxID_weight3
#the p-values are going to be summarised in a table

t_table <- data.frame(GLOBALxIDw1 = rep(0, 10), GLOBALxIDw3 = rep(0, 10))
for(t in seq(from = 50, to = 500, by = 50)){
  t_table$GLOBALxIDw1[[t/50]] <- t.test(x = na.omit(SD[index_IDw1, t/10+2]), y = na.omit(SD[, t/10+2]))$p.value
  t_table$GLOBALxIDw3[[t/50]] <- t.test(x = na.omit(SD[index_IDw3, t/10+2]), y = na.omit(SD[, t/10+2]))$p.value
}

ind = which(t_table > 0.05)
print(ind) #displays "integer(0)". All results are highly significant!!
