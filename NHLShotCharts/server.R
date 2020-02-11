# server.R

### Start Reactive Function ###

shinyServer(function(input, output, session) {
  
  # Generate your plot using ggvis with reactive inputs      
  gv <- reactive({
    
    # Change error message if no player is selected
    validate(
      need(input$player != "", "Please select a player from the dropdown.")
    )
    
    # If no player is selected, return NULL so that it doesn't load all players at once.  Slows down the app.
    if (input$player == "")
      return(NULL)
    
    if (input$player %in% shots$player_fullName)
      shots <- shots[which(shots$player_fullName==input$player),]
      shots <- subset(shots, result_secondaryType %in% input$shot_type)
      shots <- subset(shots, about_period %in% input$period)
      shots <- subset(shots, result_strength_name %in% input$strength_name | is.na(result_strength_name))
      shots <- subset(shots, about_dateTime >= input$dateRange[1] & about_dateTime <= input$dateRange[2])
  })
  
  output$plot<-renderPlotly({  
    
    # team colors - https://teamcolorcodes.com/nhl-team-color-codes/
    shot_color <- unique(ifelse(gv()$team_triCode == 'NJD', "#CE1126", 
                          ifelse(gv()$team_triCode == "NYI",  "#00539B",
                          ifelse(gv()$team_triCode == "NYR",  "#0038A8",
                          ifelse(gv()$team_triCode == "PHI",  "#F74902",
                          ifelse(gv()$team_triCode == "PIT",  "#000000",
                          ifelse(gv()$team_triCode == "BOS",  "#FFB81C",
                          ifelse(gv()$team_triCode == "BUF",  "#002654",
                          ifelse(gv()$team_triCode == "MTL",  "#AF1E2D",
                          ifelse(gv()$team_triCode == "OTT",  "#C52032",
                          ifelse(gv()$team_triCode == "TOR",  "#00205B",
                          ifelse(gv()$team_triCode == "CAR",  "#CC0000",
                          ifelse(gv()$team_triCode == "FLA",  "#041E42",
                          ifelse(gv()$team_triCode == "TBL",  "#002868",
                          ifelse(gv()$team_triCode == "WSH",  "#041E42",
                          ifelse(gv()$team_triCode == "CHI",  "#CF0A2C",
                          ifelse(gv()$team_triCode == "DET",  "#CE1126",
                          ifelse(gv()$team_triCode == "NSH",  "#FFB81C",
                          ifelse(gv()$team_triCode == "STL",  "#002F87",
                          ifelse(gv()$team_triCode == "CGY",  "#F1BE48",
                          ifelse(gv()$team_triCode == "COL",  "#236192",
                          ifelse(gv()$team_triCode == "EDM",  "#041E42",
                          ifelse(gv()$team_triCode == "VAN",  "#00205B",
                          ifelse(gv()$team_triCode == "ANA",  "#F47A38",
                          ifelse(gv()$team_triCode == "DAL",  "#006847",
                          ifelse(gv()$team_triCode == "LAK",  "#111111",
                          ifelse(gv()$team_triCode == "SJS",  "#006D75",
                          ifelse(gv()$team_triCode == "CBJ",  "#002654",
                          ifelse(gv()$team_triCode == "MIN",  "#A6192E",
                          ifelse(gv()$team_triCode == "WPG",  "#041E42",
                          ifelse(gv()$team_triCode == "ARI",  "#8C2633",
                          ifelse(gv()$team_triCode == "VGK",  "#B4975A",
                          "grey"))))))))))))))))))))))))))))))))
    
    goal_color <- unique(ifelse(gv()$team_triCode == 'NJD', "#000000", 
                         ifelse(gv()$team_triCode == "NYI",  "#F47D30",
                         ifelse(gv()$team_triCode == "NYR",  "#CE1126",
                         ifelse(gv()$team_triCode == "PHI",  "#000000",
                         ifelse(gv()$team_triCode == "PIT",  "#FCB514",
                         ifelse(gv()$team_triCode == "BOS",  "#000000",
                         ifelse(gv()$team_triCode == "BUF",  "#FCB514",
                         ifelse(gv()$team_triCode == "MTL",  "#192168",
                         ifelse(gv()$team_triCode == "OTT",  "#000000",
                         ifelse(gv()$team_triCode == "TOR",  "#000000",
                         ifelse(gv()$team_triCode == "CAR",  "#000000",
                         ifelse(gv()$team_triCode == "FLA",  "#C8102E",
                         ifelse(gv()$team_triCode == "TBL",  "#000000",
                         ifelse(gv()$team_triCode == "WSH",  "#C8102E",
                         ifelse(gv()$team_triCode == "CHI",  "#000000",
                         ifelse(gv()$team_triCode == "DET",  "#000000",
                         ifelse(gv()$team_triCode == "NSH",  "#041E42",
                         ifelse(gv()$team_triCode == "STL",  "#FCB514",
                         ifelse(gv()$team_triCode == "CGY",  "#000000",
                         ifelse(gv()$team_triCode == "COL",  "#6F263D",
                         ifelse(gv()$team_triCode == "EDM",  "#FF4C00",
                         ifelse(gv()$team_triCode == "VAN",  "#99999A",
                         ifelse(gv()$team_triCode == "ANA",  "#000000",
                         ifelse(gv()$team_triCode == "DAL",  "#111111",
                         ifelse(gv()$team_triCode == "LAK",  "#A2AAAD",
                         ifelse(gv()$team_triCode == "SJS",  "#000000",
                         ifelse(gv()$team_triCode == "CBJ",  "#CE1126",
                         ifelse(gv()$team_triCode == "MIN",  "#154734",
                         ifelse(gv()$team_triCode == "WPG",  "#AC162C",
                         ifelse(gv()$team_triCode == "ARI",  "#111111",
                         ifelse(gv()$team_triCode == "VGK",  "#000000",
                         "darkgreen"))))))))))))))))))))))))))))))))
    
    
    p <- ggplot(data = gv(), aes(x = coordinates_x, y = coordinates_y,
                          text = paste('Result: ', result_event,
                                       '<br>Shot Type: ', result_secondaryType,
                                       '<br>Period: ', about_period,
                                       paste('<br>Score: ', home_team, about_goals_home, "vs", away_team, about_goals_away),
                                       '<br>Strength Type: ', result_strength_name,
                                       '<br>Description: ', result_description,
                                       '<br>Date: ', about_dateTime,
                                       '<br>Player\'s Team: ', team_name))) +
      gg_rink(side = "right", specs = "nhl") +
      gg_rink(side = "left", specs = "nhl") +
      geom_point(aes(color = result_event , shape = result_event),
                 position = "jitter", size = 2, alpha = 1, stroke = .5) +
      labs(x = NULL, y = NULL) +
      annotate("text", x = 2.5, y = 50, size = 4.75, label = paste(gv()$player_fullName, "- Shot Chart", sep=" ")) +
      annotate("text", x = 2.5, y = -50, label = paste(min(gv()$about_dateTime), 'to', max(gv()$about_dateTime), sep=' ')) + 
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
  }) 
  
  output$text1 <- renderText({HTML(paste("- The score in the shot chart hover is the score at the time of the shot or goal. It includes the goal if the shot was scored.",
                                         "<br>- The home team is listed second in the score of the shot chart hover.", sep = "<br/>"))
  })
  
  
})

