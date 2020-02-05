# server.R

shinyServer(function(input, output, session) {
  
  
  # Generate your plot using ggvis with reactive inputs      
  gv <- reactive({
    if (input$player %in% shots$player_fullName) 
      shots <- shots[which(shots$player_fullName==input$player),]
    shots <- subset(shots, result_secondaryType %in% input$shot_type)
    shots <- subset(shots, about_period %in% input$period)
  })
  
  output$plot<-renderPlotly({  
    p <- ggplot(data = gv(), aes(x = coordinates_x, y = coordinates_y,
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
      labs(title = paste(input$player, "- Shot Chart", sep=" "),
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
  }) 
  
  # Output data table
  #output$table <- renderDataTable({
  #  df <- shots
  #  df[, c("player_fullName")]
  #names(events)[names(events) == 'player_fullName'] <- 'Player'
  #unique(df[, c("player_fullName")])
  # })
  
  # Aggregate output data table .... waiting for 2014 data in Lahman database
  output$table <- DT::renderDataTable({  
    dt <- data.table(players)
    dt <- dt[order(dt$lastName)]
    dt <- dt[, c("fullName")]
    setnames(dt, "fullName", "Full Name")
  })
  
})

