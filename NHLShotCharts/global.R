library(nhlscrape)
library(dplyr)
library(ggplot2)
library(RSQLite)
library(data.table)
library(shiny)
library(shinydashboard)
library(plotly)
library(tidyr)
library(lubridate)

### Extract data from SQLite Table ###
mydb <- dbConnect(RSQLite::SQLite(), "data/nhl2019_2020.sqlite")
events <- dbGetQuery(mydb, 'SELECT *
                            FROM events')
players <- dbGetQuery(mydb, 'SELECT * FROM players')
teams <- dbGetQuery(mydb, 'SELECT * FROM teams')
game_info <- dbGetQuery(mydb, 'SELECT * FROM game_info')

# Insert hockey rink
source('gg-rink.R')

# change datetime format from UTC to EST
events$about_dateTime <- ymd_hms(events$about_dateTime, tz = "America/New_York")
events$about_dateTime <- as.Date(events$about_dateTime, "EST")

shots <- events %>%
  # remove shots below goal line
  filter(abs(coordinates_x) <= 90) %>%
  filter(result_event == 'Shot' | result_event == 'Goal' & (playerType == 'Scorer' | playerType == 'Shooter'))

# merge game info to get home and away team
shots <- merge(x = shots, y = game_info[ , c("game_id", "home_team", "away_team", "venue")], by = "game_id", all.x=TRUE)

