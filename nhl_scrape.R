library(nhlscrape)
library(dplyr)
library(ggplot2)
library(RSQLite)
library(data.table)
library(plotly)
library(lubridate)

# Get Rinks
#source('~/GitHub/nhl_shot_charts/draw_rink.R')
source('~/GitHub/nhl_shot_charts/gg-rink.R')

# Set db path to somewhere
SetDbPath("~/GitHub/nhl_shot_charts/NHLShotCharts/data/nhl2019_2020.sqlite")

# Select all teams
#AddAllTeamsDb()

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
  gids <- GetGameIdRange(team_id, "2020-02-09", "2020-02-09")
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
setwd('~/GitHub/nhl_shot_charts/data/')
mydb <- dbConnect(RSQLite::SQLite(), "nhl2019_2020.sqlite")
events <- dbGetQuery(mydb, 'SELECT *
                            FROM events')
players <- dbGetQuery(mydb, 'SELECT * FROM players')
teams <- dbGetQuery(mydb, 'SELECT * FROM teams')

# change datetime format from UTC to EST
events$about_dateTime <- ymd_hms(events$about_dateTime, tz = "America/New_York")
events$about_dateTime <- as.Date(events$about_dateTime, "EST")

shots <- events %>%
  # remove shots below goal line
  filter(abs(coordinates_x) <= 90) %>%
  filter(result_event == 'Shot' | result_event == 'Goal' & (playerType == 'Scorer' | playerType == 'Shooter')) %>%
  filter(player_fullName == 'J.T. Compher')

shots <- shots %>% group_by(result_event) %>% mutate(shot_type_count = n())  # get count by group to order point layers in ggplot

# team colors - https://teamcolorcodes.com/nhl-team-color-codes/
shot_color <- unique(ifelse(shots$team_triCode == 'NJD', "#CE1126", 
                            ifelse(shots$team_triCode == "NYI",  "#00539B",
                            ifelse(shots$team_triCode == "NYR",  "#0038A8",
                            ifelse(shots$team_triCode == "PHI",  "#F74902",
                            ifelse(shots$team_triCode == "PIT",  "#000000",
                            ifelse(shots$team_triCode == "BOS",  "#FFB81C",
                            ifelse(shots$team_triCode == "BUF",  "#002654",
                            ifelse(shots$team_triCode == "MTL",  "#AF1E2D",
                            ifelse(shots$team_triCode == "OTT",  "#C52032",
                            ifelse(shots$team_triCode == "TOR",  "#00205B",
                            ifelse(shots$team_triCode == "CAR",  "#CC0000",
                            ifelse(shots$team_triCode == "FLA",  "#041E42",
                            ifelse(shots$team_triCode == "TBL",  "#002868",
                            ifelse(shots$team_triCode == "WSH",  "#041E42",
                            ifelse(shots$team_triCode == "CHI",  "#CF0A2C",
                            ifelse(shots$team_triCode == "DET",  "#CE1126",
                            ifelse(shots$team_triCode == "NSH",  "#FFB81C",
                            ifelse(shots$team_triCode == "STL",  "#002F87",
                            ifelse(shots$team_triCode == "CGY",  "#F1BE48",
                            ifelse(shots$team_triCode == "COL",  "#236192",
                            ifelse(shots$team_triCode == "EDM",  "#041E42",
                            ifelse(shots$team_triCode == "VAN",  "#00205B",
                            ifelse(shots$team_triCode == "ANA",  "#F47A38",
                            ifelse(shots$team_triCode == "DAL",  "#006847",
                            ifelse(shots$team_triCode == "LAK",  "#111111",
                            ifelse(shots$team_triCode == "SJS",  "#006D75",
                            ifelse(shots$team_triCode == "CBJ",  "#002654",
                            ifelse(shots$team_triCode == "MIN",  "#A6192E",
                            ifelse(shots$team_triCode == "WPG",  "#041E42",
                            ifelse(shots$team_triCode == "ARI",  "#8C2633",
                            ifelse(shots$team_triCode == "VGK",  "#B4975A",
                            "grey"))))))))))))))))))))))))))))))))
                            
goal_color <- unique(ifelse(shots$team_triCode == 'NJD', "##000000", 
                            ifelse(shots$team_triCode == "NYI",  "#F47D30",
                            ifelse(shots$team_triCode == "NYR",  "#CE1126",
                            ifelse(shots$team_triCode == "PHI",  "#000000",
                            ifelse(shots$team_triCode == "PIT",  "#FCB514",
                            ifelse(shots$team_triCode == "BOS",  "#000000",
                            ifelse(shots$team_triCode == "BUF",  "#FCB514",
                            ifelse(shots$team_triCode == "MTL",  "#192168",
                            ifelse(shots$team_triCode == "OTT",  "#000000",
                            ifelse(shots$team_triCode == "TOR",  "#000000",
                            ifelse(shots$team_triCode == "CAR",  "#000000",
                            ifelse(shots$team_triCode == "FLA",  "#C8102E",
                            ifelse(shots$team_triCode == "TBL",  "#000000",
                            ifelse(shots$team_triCode == "WSH",  "#C8102E",
                            ifelse(shots$team_triCode == "CHI",  "#000000",
                            ifelse(shots$team_triCode == "DET",  "#000000",
                            ifelse(shots$team_triCode == "NSH",  "#041E42",
                            ifelse(shots$team_triCode == "STL",  "#FCB514",
                            ifelse(shots$team_triCode == "CGY",  "#000000",
                            ifelse(shots$team_triCode == "COL",  "#6F263D",
                            ifelse(shots$team_triCode == "EDM",  "#FF4C00",
                            ifelse(shots$team_triCode == "VAN",  "#99999A",
                            ifelse(shots$team_triCode == "ANA",  "#000000",
                            ifelse(shots$team_triCode == "DAL",  "#111111",
                            ifelse(shots$team_triCode == "LAK",  "#A2AAAD",
                            ifelse(shots$team_triCode == "SJS",  "#000000",
                            ifelse(shots$team_triCode == "CBJ",  "#CE1126",
                            ifelse(shots$team_triCode == "MIN",  "#154734",
                            ifelse(shots$team_triCode == "WPG",  "#AC162C",
                            ifelse(shots$team_triCode == "ARI",  "#111111",
                            ifelse(shots$team_triCode == "VGK",  "#000000",
                            "darkgreen"))))))))))))))))))))))))))))))))

ggplot(shots, aes(x = coordinates_x, y = coordinates_y)) +
  gg_rink(side = "right", specs = "nhl") +
  gg_rink(side = "left", specs = "nhl") +
  geom_point(aes(color = result_event , shape = result_event),
             position = "jitter", size = 2, alpha = 1, stroke = .5) +
  labs(title = paste(shots$player_fullName, "- Shot Chart", sep=" "),
       subtitle = paste(min(shots$about_dateTime), 'to', max(shots$about_dateTime), sep=' '), # time is in UTC to subtract one day 
       x = NULL,
       y = NULL) +
  scale_color_manual(values = c("Shot" = shot_color, "Goal" = goal_color),
                     name = NULL) +
  scale_shape_manual(values = c("Shot" = 4, "Goal" = 16),
                     name = NULL) +
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

p <- ggplot(shots, aes(x = coordinates_x, y = coordinates_y,
                       text = paste('Result: ', result_event,
                                    '<br>Shot Type: ', result_secondaryType,
                                    '<br>Period: ', about_period,
                                    '<br>Away Goals: ', about_goals_away, 
                                    '<br>Home Goals (goal included if scored): ', about_goals_home,
                                    '<br>Team Name: ', team_name, 
                                    '<br>Strength Type: ', result_strength_name,
                                    '<br>Description: ', result_description))) +
  gg_rink(side = "right", specs = "nhl") +
  gg_rink(side = "left", specs = "nhl") +
  geom_point(aes(color = result_event , shape = result_event),
             position = "jitter", size = 2, alpha = 1, stroke = .5) +
  labs(x = NULL,
       y = NULL) +
  annotate("text", x = 2.5, y = 50, size = 4.75, label = paste(shots$player_fullName, "- Shot Chart", sep=" ")) +
  annotate("text", x = 2.5, y = -50, label = paste(min(shots$about_dateTime), 'to', max(shots$about_dateTime), sep=' ')) + 
  scale_color_manual(values = c("Shot" = shot_color, "Goal" = goal_color),
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
