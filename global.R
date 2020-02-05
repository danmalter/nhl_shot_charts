library(nhlscrape)
library(dplyr)
library(ggplot2)
library(RSQLite)
library(data.table)
library(shiny)
library(shinydashboard)
library(plotly)

# Get Rinks
source('~/Documents/nhl/draw_rink.R')
source('~/Documents/nhl/gg-rink.R')

# Set db path to somewhere
#SetDbPath("~/Documents/nhl/data/nhl.sqlite")

# Select the leafs
#AddAllTeamsDb()

# Add single game
# team_id <- GetTeamId("CHI")
# gids <- GetGameIdRange(16, "2019-12-02", "2019-12-02")
# AddGameEvents(gids)

# Add multiple games
#team_list <- list("NJD", "NYI", "NYR", "PHI", "PIT", "BOS", "BUF", "MTL", "OTT", "TOR", "CAR", "FLA", "TBL", "WSH", "CHI", "DET",
#                  "NSH", "STL", "CGY", "COL", "EDM", "VAN", "ANA", "DAL", "LAK", "SJS", "CBJ", "MIN", "WPG", "ARI", "VGK")

#team_id_list <- list()
#for (team in team_list){
#  team_id <- GetTeamId(team)
#  gids <- GetGameIdRange(team_id, "2020-02-04", "2020-02-04")
#  ps <- team  ## where i is whatever your ps is
#  team_id_list[[team]] <- gids
#}

#new_team_list <- unique(team_id_list)
#for (team in new_team_list){
#  AddGameEvents(team)
#}


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
  filter(result_event == 'Shot' | result_event == 'Goal' & (playerType == 'Scorer' | playerType == 'Shooter'))