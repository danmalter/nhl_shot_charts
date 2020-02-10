## ui.R
shinyUI(dashboardPage(skin="black",
                      dashboardHeader(title = "NHL Shot Charts"),
                      dashboardSidebar(width = 275,
                        sidebarMenu(
                          menuItem("Shot Charts", tabName = "offensiveShotChart", icon = icon("star-o")),
                          menuItem("About", tabName = "about", icon = icon("question-circle")),
                          menuItem("Source code", icon = icon("file-code-o"), 
                                   href = "https://github.com/danmalter/nhl_shot_charts"),
                          menuItem(
                            list(selectizeInput("player", label = h5("Player Name"), choices = players[order(players[, "lastName"]), "fullName", drop = FALSE], selected = "J.T. Compher"),
                                 HTML
                                 ("<div style='font-size: 12px;'> Search above for players. Loading may take <br> a few seconds.</div>"))),
                          menuItem(
                            dateRangeInput('dateRange',
                                           label = span(tagList(icon("calendar"), "Date Range:")),
                                           start = min(events$about_dateTime), max(events$about_dateTime),
                                           format = "yyyy-mm-dd"))
                        ),
                          menuItem(
                            checkboxGroupInput("shot_type", 
                                               label = span(tagList(icon("hockey-puck"), " Shot Type:")),
                                               c("Backhand", "Slap Shot", "Snap Shot", "Tip-In", "Wrap-around", "Wrist Shot"),
                                               selected=c("Backhand", "Slap Shot", "Snap Shot", "Tip-In", "Wrap-around", "Wrist Shot"), 
                                               inline = TRUE)), 
                          menuItem(
                            checkboxGroupInput("period", 
                                               label = span(tagList(icon("clipboard"), " Period:")),
                                               c("1", "2", "3", "4", "5"),
                                               selected=c("1", "2", "3"), 
                                               inline = TRUE))
                      ),
  
                      dashboardBody(
                        tags$head(
                          tags$style(type="text/css", "select { max-width: 360px; }"),
                          tags$style(type="text/css", ".span4 { max-width: 360px; }"),
                          tags$style(type="text/css",  ".well { max-width: 360px; }"),
                          tags$style(
                            HTML(
                              ".checkbox-inline { 
                                margin-left: 0px;
                                margin-right: 10px;
                                }
                                .checkbox-inline+.checkbox-inline {
                                margin-left: 0px;
                                margin-right: 10px;
                                }"
                              )
                          )
                        ),
                        tags$head(includeScript("google-analytics.js")),
                        tabItems(  
                          tabItem(tabName = "about",
                                  h2("About this App"),
                                  
                                  HTML('<br/>'),
                                  
                                  fluidRow(
                                    box(title = "Author: Danny Malter", status="primary", width=10, collapsible = TRUE,
                                        
                                        helpText(p(strong("This application shows the shot chart for the selected NHL players for the 2019-2020 season.  All data is from statsapi.web.nhl.com."))),
                                        
                                        helpText(p("You can find me or reach out for more information at my personal page",  a(href ="http://danmalter.github.io/", "here.", target = "_blank"), 
                                                   "To suggest improvements or report errorts, please do so", a(href ="https://github.com/danmalter/nhl_shot_charts/issues", "here.", target = "_blank"))),
                                        helpText(p("All code and data is available at my",
                                                   a(href ="https://github.com/danmalter/nhl_shot_charts", "GitHub page",target = "_blank"),
                                                   "or click the 'source code' tab on the left sidebar."
                                        )
                                      )
                                    )
                                  )
                          ),
                          tabItem(tabName = "offensiveShotChart",
                                  box(plotlyOutput("plot"), title = "NHL Shot Charts - 2019-2020", status="primary", width=10, collapsible = TRUE))
                                  #,
                                  #HTML('<br/>'),
                                  #box(DT::dataTableOutput("table"), title = "Table of Players", width=12, collapsible = TRUE))
                          
                        )
                        
                        
                        
                      )
                      
)
)