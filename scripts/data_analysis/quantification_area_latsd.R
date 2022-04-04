################## This script quantifies the relation between plate area and lat sd ##################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com

store <- readRDS("./data/plate_areas/cross_categorisation.RDS")

final <- data.frame(TIME = rep(0, length(unique(store$cross_cat))),
                    AVERAGE_METRIC = rep(0, length(unique(store$cross_cat))),
                    ID_w = c("ID_score = 1", "ID_score = 2", "ID_score = 3"),
                    CI_95 = rep(0, length(unique(store$cross_cat))))