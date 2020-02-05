library(ggplot2)
library(progress)
library(tibble)

# Scrapes the NHL API for Shot Location Data

scrape_shots <- function(start_season=2018, end_season=2019){
  if(start_season > 2019){stop("That season has not begun yet.")}
  if(start_season > end_season){stop("start_season must be before end_season")}
  if(!is.numeric(start_season)){stop("start_season must be an integer")}
  if(!is.numeric(end_season)){stop("end_season must be an integer")}
  if(start_season==end_season){years <- start_season}
  if(start_season < end_season){years <- start_season:end_season}
  urls <- NULL
  for(year in years){
    if(year >= 2017){gms <- 1271}
    if(year < 2017){gms <- 1230}
    gms <- 10  #### DELETE LINE
    for(gm in 1:gms){
      game_num= formatC(gm, width=4, flag="0")
      game_id = paste0(as.character(year),"02",game_num)
      
      #game_id = "2016020001"
      
      url = paste0("https://statsapi.web.nhl.com/api/v1/game/",game_id,"/feed/live")
      urls <- c(urls, url)
    }
  }
  shot_types <- c("SHOT","MISSED_SHOT","BLOCKED_SHOT","GOAL")
  shot_df <- data.frame()
  pb <- progress_bar$new(total = length(urls))
  
  #datalist = list()
  
  for(u in 1:length(urls)){
    if(httr::http_error(urls[u])==TRUE){next} # skip URLs that don't exist
    whole_file <- jsonlite::fromJSON(curl::curl(urls[u]))
    all_plays <- whole_file$liveData$plays$allPlays
    if(length(all_plays)==0){next} # some games don't include play-by-play data
    event_type <- whole_file$liveData$plays$allPlays$result$eventTypeId
    for(p in 1:nrow(all_plays)){
      if(event_type[p] %in% shot_types){
        play <- tibble::tibble(eventID = all_plays$about$eventId[p],
                               shot_type = all_plays$result$event[p],
                               shot_type_secondary = all_plays$result$secondaryType[p],
                               eventCode = all_plays$result$eventCode[p],
                               shooter_id = all_plays$players[p][[1]]$player$id[all_plays$players[p][[1]]$playerType=="Shooter" | all_plays$players[p][[1]]$playerType=="Scorer"],
                               shooter = all_plays$players[p][[1]]$player$fullName[all_plays$players[p][[1]]$playerType=="Shooter" | all_plays$players[p][[1]]$playerType=="Scorer"],
                               team = all_plays$team$name[p],
                               x = all_plays$coordinates$x[p],
                               y = all_plays$coordinates$y[p],
                               penalty_minutes = all_plays$result$penaltyMinutes[p],
                               strength_code = ifelse(is.null(all_plays$result$strength.code[p]), NA, all_plays$result$strength.code[p]),
                               strength_name = ifelse(is.null(all_plays$result$strength.name[p]), NA, all_plays$result$strength.name[p]),
                               game_winning_goal = all_plays$result$gameWinningGoal[p],
                               empty_net = ifelse(is.null(all_plays$result$emptyNet[p]), NA, all_plays$result$emptyNet[p]),
                               period = all_plays$about$period[p],
                               period_type = all_plays$about$periodType[p],
                               period_time_remaining = all_plays$about$periodTimeRemaining[p],
                               goals_away = ifelse(is.null(all_plays$result$goals.away[p]), NA, all_plays$result$goals.away[p]),
                               goals_home = ifelse(is.null(all_plays$result$goals.home[p]), NA, all_plays$result$goals.home[p]),
                               date_time = all_plays$about$dateTime[p])
        shot_df <- data.frame(rbind(shot_df, play))
        
        #shot_df$p <- p  # maybe you want to keep track of which iteration produced it?
        #datalist[[p]] <- shot_df # add it to your list
      }
      
      #shot_df <- data.frame(play)
      
      #shot_df$p <- p  # maybe you want to keep track of which iteration produced it?
      #datalist[[p]] <- shot_df # add it to your list
    }
    pb$tick()
    Sys.sleep(1 / 100)
    #print(urls[u])
  }
  return(shot_df)
  #big_data = do.call(rbind, datalist)
}

scrape_shots(start_season=2018, end_season=2019)

source('~/Documents/nhl/draw_rink.R')

ggplot(shot_df, aes(x = X/3.281, y = Y/3.281)) +
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
