## ui.R


shinyUI(dashboardPage(skin="black",
                      dashboardHeader(title = "NHL Shot Charts"),
                      dashboardSidebar(
                        sidebarMenu(
                          menuItem("Shot Charts", tabName = "offensiveShotChart", icon = icon("star-o")),
                          menuItem("About", tabName = "about", icon = icon("question-circle")),
                          menuItem("Source code", icon = icon("file-code-o"), 
                                   href = "https://github.com/danmalter/nhl_shot_charts"),
                          menuItem(
                            list(textInput("player", label = h5("Player Name"), value="J.T. Compher"),
                                 HTML
                                 ("<div style='font-size: 12px;'> Player name must be spelled correctly. <br> Search for names below. </div>"))),
                          menuItem(
                            checkboxGroupInput("shot_type", label = h5("Shot Type:"),
                                               c("Backhand", "Slap Shot", "Snap Shot", "Tip-In", "Wrap-around", "Wrist Shot"),
                                               selected=c("Slap Shot", "Snap Shot", "Wrist Shot"), 
                                               inline = TRUE)), 
                          menuItem(
                            checkboxGroupInput("period", label = h5("Period:"),
                                               c("1", "2", "3", "4", "5"),
                                               selected=c("1", "2", "3"), 
                                               inline = TRUE))  
                        )
                      )
                      ,
                      
                      
                      dashboardBody(
                        tags$head(
                          tags$style(type="text/css", "select { max-width: 360px; }"),
                          tags$style(type="text/css", ".span4 { max-width: 360px; }"),
                          tags$style(type="text/css",  ".well { max-width: 360px; }")
                        ),
                        
                        tabItems(  
                          tabItem(tabName = "about",
                                  h2("About this App"),
                                  
                                  HTML('<br/>'),
                                  
                                  fluidRow(
                                    box(title = "Author: Danny Malter", background = "black", width=7, collapsible = TRUE,
                                        
                                        helpText(p(strong("This application shows the shot chart for the selected NHL players.  X and Y coordinates are from nhl.com"))),
                                        
                                        helpText(p("Please contact",
                                                   a(href ="https://twitter.com/danmalter", "Danny on twitter",target = "_blank"),
                                                   " or at my",
                                                   a(href ="http://danmalter.github.io/", "personal page", target = "_blank"),
                                                   ", for more information, to suggest improvements or report errors.")),
                                        
                                        helpText(p("All code and data is available at ",
                                                   a(href ="https://github.com/danmalter/nhl_shot_charts", "my GitHub page",target = "_blank"),
                                                   "or click the 'source code' link on the sidebar on the left."
                                        ))
                                        
                                    )
                                  )
                          ),
                          tabItem(tabName = "offensiveShotChart",
                                  
                                  box(plotlyOutput("plot"), title = "NHL Shot Charts - 2019-2020", width=12, collapsible = TRUE),
                                  HTML('<br/>'),
                                  box(DT::dataTableOutput("table"), title = "Table of Players", width=12, collapsible = TRUE))
                          
                        )
                        
                        
                        
                      )
                      
)
)