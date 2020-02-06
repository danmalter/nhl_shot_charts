library(ggplot2)
library(here)

source('./nhl/draw_rink.R')

setwd('./nhl/data')
#looping through - STEP 1
gamenumber <- 0
for(i in 1:5) {
  g <- nchar(i)
  if(g==1) { 
    nr <- paste0("000", i)
  } else if (g==2) {
    nr <- paste0("00", i)
  } else if (g==3) {
    nr <- paste0("0", i)
  } else nr <- paste0("", i)
  
  gamenumber <- paste("game201902", nr, sep = "")
  gamelist <- paste("L", gamenumber, sep = "")
  gamelinknumber <- paste("201902", nr, sep = "")
  gamelink <- paste("http://statsapi.web.nhl.com/api/v1/game/",gamelinknumber,"/feed/live", sep="")
  
  assign(gamenumber, fromJSON(gamelink))
  #  game016020015b <- fromJSON("http://statsapi.web.nhl.com/api/v1/game/2016020015/feed/live") #manual try
  
  mylist99 <- get(gamenumber)$liveData$plays$allPlays #as.name(gamelist) #game2017020001$liveData$plays$allPlays 
  TEST1 <- NROW(mylist99)
  #print(TEST1)
  if (TEST1>0) {
    tryCatch(gameslistcsv <-
               data.frame(unlist(mylist99[[1]][[4]]) #result.description
                          ,unlist(mylist99[[2]][[2]]) #about.eventId
                          ,as.integer(unlist(mylist99[[3]][[1]])) #coordinates.x
                          ,as.integer(unlist(mylist99[[3]][[2]])) #coordinates.y
                          ,unlist(mylist99[[1]][[1]]) #result.event
                          ,unlist(mylist99[[1]][[2]]) #result.eventcode
                          ,unlist(mylist99[[1]][[5]]) #result.secondarytype
                          ,unlist(mylist99[[1]][[8]][[1]]) #result.strengthcode
                          ,unlist(mylist99[[2]][[3]]) #about.period
                          ,unlist(mylist99[[2]][[6]]) #about.periodtime
                          # #        ,unlist(mylist[[4]][[2]][[1]][[2]]) #players.'data.frame'.player.fullname
                          ,unlist(mylist99[[5]][[2]]) #team.names
               ), error = function(e) gamenumber <- paste("E",gamenumber, sep = "")) #print(paste("Error with ", gamenumber, "!", sep = "")))
    
    rownames(gameslistcsv) <- NULL # remove automatically created rownames
    gameslistcsv$newcolumn<-gamelist
    tryCatch(colnames(gameslistcsv)[12] <- "Sourcegame", error = function(e) print("T"))
    names(gameslistcsv) <- c("Description", "EventID", "X", "Y", "Event", "EventCode", "Subtype", "Strength", "Period", "PeriodTime", "TeamName") # rename the headers
    #filename = paste(gamenumber,".csv",sep = "")
    write.csv(gameslistcsv, file = paste(gamenumber,".csv",sep = ""), row.names = FALSE) # write the file to csv (without automatically created row names) in the workdirectory
    #system.time(5)
    gameslistcsv <- "error with source"
  }
}





df <- read.csv('C:/Users/NU76/OneDrive - Molson Coors Brewing Company/Desktop/nhl/game2015020001.csv')

library(dplyr)
scf2010 <- readRDS(here::here("hockey-with-r", "scf2010.rds"))
shots <- df %>%
  # remove shots below goal line
  dplyr::filter(abs(X) <= 90) %>%
  filter(Event == 'Shot' | Event == 'Goal')

ggplot(shots, aes(x = X, y = Y)) +
  gg_rink(side = "right") +
  geom_point(aes(color = Event, shape = Event),
             position = "jitter", size = 1.5, alpha = 0.7) +
  labs(title = "shot chart",
       subtitle = "2010 Stanley Cup playoffs",
       x = NULL,
       y = NULL) +
  scale_color_manual(values = c("Shot" = "gray", "Goal" = "green"),
                     name = NULL) +
  scale_shape_manual(values = c("Shot" = 4, "Goal" = 16),
                     name = NULL) +
  scale_x_continuous(breaks = seq(0, 100, by = 10)) +
  scale_y_continuous(breaks = seq(-40, 40, by = 10))



ggplot(shots, aes(x = X/3.281, y = Y/3.281)) +
  gg_rink(side = "right", specs = "iihf") +
  gg_rink(side = "left", specs = "iihf") +
  geom_point(aes(color = Event , shape = Event),
             position = "jitter", size = 1.5, alpha = 0.7) +
  labs(title = "shot chart: 2010 NHL playoffs",
       subtitle = "IIHF rink",
       x = NULL,
       y = NULL) +
  scale_color_manual(values = c("Shot" = "gray", "Goal" = "green"),
                     name = NULL) +
  scale_shape_manual(values = c("Shot" = 4, "Goal" = 16),
                     name = NULL) +
  scale_x_continuous(breaks = seq(-30, 30, by = 5)) +
  scale_y_continuous(breaks = seq(-15, 15, by = 3))
