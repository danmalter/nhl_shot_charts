library(nhlscrape)
library(dplyr)
library(ggplot2)
library(RSQLite)
library(data.table)

# Get Rinks
source('~/Documents/nhl/draw_rink.R')
source('~/Documents/nhl/gg-rink.R')

# Set db path to somewhere
SetDbPath("~/Documents/nhl/data/nhl.sqlite")

# Select the leafs
AddAllTeamsDb()

# Add single game
# team_id <- GetTeamId("CHI")
# gids <- GetGameIdRange(16, "2019-12-02", "2019-12-02")
# AddGameEvents(gids)

# Add multiple games
team_list <- list("NJD", "NYI", "NYR", "PHI", "PIT", "BOS", "BUF", "MTL", "OTT", "TOR", "CAR", "FLA", "TBL", "WSH", "CHI", "DET",
              "NSH", "STL", "CGY", "COL", "EDM", "VAN", "ANA", "DAL", "LAK", "SJS", "CBJ", "MIN", "WPG", "ARI", "VGK")

team_id_list <- list()
for (team in team_list){
  team_id <- GetTeamId(team)
  gids <- GetGameIdRange(team_id, "2020-02-04", "2020-02-04")
  ps <- team  ## where i is whatever your ps is
  team_id_list[[team]] <- gids
}

new_team_list <- unique(team_id_list)
for (team in new_team_list){
  AddGameEvents(team)
}



# Get stats for player
# Tavares
player_id <- GetPlayerId("jonathan toews")
stats <- GetPlayerStats(player_id, gids, team_id)

### Extract data from SQLite Table ###
setwd('~/Documents/nhl/data/')
mydb <- dbConnect(RSQLite::SQLite(), "nhl.sqlite")
events <- dbGetQuery(mydb, 'SELECT *
                            FROM events')
players <- dbGetQuery(mydb, 'SELECT * FROM players')
teams <- dbGetQuery(mydb, 'SELECT * FROM teams')

shots <- events %>%
  # remove shots below goal line
  filter(abs(coordinates_x) <= 90) %>%
  filter(result_event == 'Shot' | result_event == 'Goal' & (playerType == 'Scorer' | playerType == 'Shooter')) %>%
  filter(player_fullName == 'J.T. Compher')

ggplot(shots, aes(x = coordinates_x, y = coordinates_y)) +
  gg_rink(side = "right", specs = "nhl") +
  gg_rink(side = "left", specs = "nhl") +
  geom_point(aes(color = result_event , shape = result_event),
             position = "jitter", size = 1.5, alpha = .75, stroke = .5) +
  labs(title = paste(shots$player_fullName, "- Shot Chart", sep=" "),
       subtitle = paste(format(min(as.Date(shots$about_dateTime)), format = "%m/%d/%Y"), 'to', format(max(as.Date(shots$about_dateTime)), format = "%m/%d/%Y"), sep=' '),
       x = NULL,
       y = NULL) +
  scale_color_manual(values = c("Shot" = "black", "Goal" = "green"),
                     name = NULL) +
  scale_shape_manual(values = c("Shot" = 4, "Goal" = 16),
                     name = NULL, ) +
  scale_x_continuous(breaks = seq(-30, 30, by = 5)) +
  scale_y_continuous(breaks = seq(-15, 15, by = 3)) + 
  theme(legend.title=element_blank(),
        legend.position="bottom",
        plot.title=element_text(hjust=0.5),
        plot.subtitle=element_text(hjust=0.5),
        axis.text.x=element_blank(),
        axis.text.y=element_blank())


# heatmap
ggplot(shots, aes(x = coordinates_x, y = coordinates_y)) +
  gg_rink(side = "right", specs = "nhl") +
  gg_rink(side = "left", specs = "nhl") +
  geom_hex(bins = 20) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

ggplot(shots, aes(x = coordinates_x, y = coordinates_y)) +
  gg_rink(side = "right", specs = "nhl") +
  gg_rink(side = "left", specs = "nhl") +
  stat_density_2d(bins = 50) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

library(plotly)
p <- ggplot(shots, aes(x = coordinates_x, y = coordinates_y,
                       text = paste('Result: ', result_event,
                                    '<br>Shot Type: ', result_secondaryType,
                                    '<br>Period: ', about_period,
                                    '<br>Away Goals: ', about_goals_away, 
                                    '<br>Home Goals (goal included if scored): ', about_goals_home,
                                    '<br>Description: ', result_description))) +
  gg_rink(side = "right", specs = "nhl") +
  gg_rink(side = "left", specs = "nhl") +
  geom_point(aes(color = result_event , shape = result_event),
             position = "jitter", size = 1.5, alpha = .75, stroke = .5) +
  labs(title = paste(shots$player_fullName, "- Shot Chart", sep=" "),
       x = NULL,
       y = NULL) +
  annotate("text", x = 2.5, y = -50, label = paste(format(min(as.Date(shots$about_dateTime)), format = "%m/%d/%Y"), 'to', format(max(as.Date(shots$about_dateTime)), format = "%m/%d/%Y"), sep=' ')) + 
  scale_color_manual(values = c("Shot" = "black", "Goal" = "green"),
                     name = NULL) +
  scale_shape_manual(values = c("Shot" = 4, "Goal" = 16),
                     name = NULL, ) +
  scale_x_continuous(breaks = seq(-30, 30, by = 5)) +
  scale_y_continuous(breaks = seq(-15, 15, by = 3)) + 
  theme(legend.title=element_blank(),
        legend.position="bottom",
        plot.title=element_text(hjust=0.5),
        plot.subtitle=element_text(hjust=0.5),
        axis.text.x=element_blank(),
        axis.text.y=element_blank())

ggplotly(p, tooltip="text")


### Player Positions ###
player_position1 <- function(df, eventid, periodTimeRemaining){
  dfall <- events %>% filter(about_periodTimeRemaining == periodTimeRemaining, about_eventId==eventid)  %>% 
    filter(about_periodTime!="00:00") %>% select (team_id, coordinates_x,coordinates_y,player_fullName)
  colnames(dfall) <- c('ID','X','Y','name')
  return(dfall)
}

chull_plot <- function(df, eventid, periodTimeRemaining) {
  df2 <- player_position1(df, eventid, periodTimeRemaining)
  df_hull2 <- df2 %>% filter(ID == min(ID)) %>% select(X,Y)
  df_hull3 <- df2 %>% filter(ID == max(ID)) %>% select(X,Y)
  c.hull2 <- chull(df_hull2)
  c.hull3 <- chull(df_hull3)
  c.hull2 <- c(c.hull2, c.hull2[1])
  c.hull3 <- c(c.hull3, c.hull3[1])
  df2 <- as.data.frame(cbind(1,df_hull2[c.hull2 ,]$X,df_hull2[c.hull2 ,]$Y))
  df3 <- as.data.frame(cbind(2,df_hull3[c.hull3 ,]$X,df_hull3[c.hull3 ,]$Y))
  dfall <- rbind(df2,df3)
  colnames(dfall) <- c('ID','X','Y')
  return(dfall)
}

compher_385 <- events[which(events$about_eventId == 385 & events$game_id == 2019020666),]

playerdf <- player_position1(df=compher_385, eventid=385, periodTimeRemaining='08:28') 
playerdf

chulldf <- chull_plot(df=compher_385, eventid=385, periodTimeRemaining='08:28')
chulldf

ggplot() + 
  geom_point(data=playerdf,aes(x=X,y=Y,group=ID,color=factor(ID)),size=6) +       #players
  geom_text(data=playerdf,aes(x=X,y=Y,group=ID,label=name),color='black') +     #jersey number
  geom_polygon(data=chulldf,aes(x=X,y=Y,group=ID,fill=factor(ID)),alpha = 0.2) +  #convex hull
  #geom_point(data=ballposdf,aes(x=X,y=Y),color='darkorange',size=3) +             #ball
  scale_color_manual(values=c("lightsteelblue2","orangered2")) +
  scale_fill_manual(values=c("lightsteelblue2","orangered2")) +
  theme(legend.position="none")
