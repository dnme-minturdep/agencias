dashboardPage(
    
    dashboardHeader(title = "AGENCIAS DE VIAJE"),
    
    dashboardSidebar(
        sidebarMenu(
            menuItem(tabName = "summary", "RESUMEN"),
            menuItem(tabName = "provinces", "PROVINCIAS"),
            menuItem(tabName = "markets", "RECEPTIVO"),
            menuItem(tabName = "students", "TURISMO ESTUDIANTIL")
        )
    ),
    
    dashboardBody(
        tags$head(tags$style(HTML(".small-box {height: 150%}"))),
        #tags$style(".fa-plane-departure {color:#51d1c2}"),
        
        tabItems(
            tabItem(
                tabName = "summary",
                
                fluidRow(
                    valueBox(tags$p(style = "font-size: 300%;", as.integer(nrow(base_agencias))),
                             tags$p(style = "font-size: 180%;", "AGENCIAS DE VIAJE EN EL PAÍS"), 
                                 icon = icon("van-shuttle fa-xl", verify_fa = FALSE), width = 6, color = "olive"),
                    
                    valueBox(tags$p(style = "font-size: 300%;", estudiantil), 
                             tags$p(style = "font-size: 180%;","AGENCIAS DE TURISMO ESTUDIANTIL"), 
                             icon = icon("school fa-xl", verify_fa = FALSE), width = 6, color = "olive")
                        ),
                
                fluidRow(
                    valueBox(tags$p(style = "font-size: 200%;", receptivo),
                             tags$p(style = "font-size: 140%;", "AGENCIAS RECEPTIVAS"), 
                             icon = icon("plane-arrival fa-xl", verify_fa = FALSE), width = 4, color = "aqua"),
                    
                    valueBox(tags$p(style = "font-size: 200%;", emisivo), 
                             tags$p(style = "font-size: 140%;","AGENCIAS EMISIVAS"), 
                             icon = icon("plane-departure fa-xl", verify_fa = FALSE), width = 4, color = "aqua"),
                    
                    valueBox(tags$p(style = "font-size: 200%;", interno), 
                             tags$p(style = "font-size: 140%;","AGENCIAS DE TURISMO INTERNO"), 
                             icon = icon("car fa-xl", verify_fa = FALSE), width = 4, color = "aqua")
                ),
                
            ),
            
            tabItem(
                tabName = "provinces",
                
                fluidRow(
                    tabBox(
                        tabPanel("MODALIDAD", dataTableOutput("tabla_provincias")),
                        tabPanel("MERCADOS DE AGENCIAS RECEPTIVAS", dataTableOutput("tabla_mercados_prov"))
                        ),
                
                    column(6, selectInput("tipo_mapa", label = NULL,
                                          choices = c("Cantidad de agencias" = "agencias_prov", 
                                                      "% receptivo" = "prop_receptivo",
                                                      "% emisivo" = "prop_emisivo",
                                                      "% interno" = "prop_interno")), 
                           leafletOutput("mapa_arg", height = 650)
                    ))
            ),
            
            tabItem(
                tabName = "markets",
                
                fluidRow(
                    box(status = "primary", solidHeader = TRUE,
                        title = "AGENCIAS RECEPTIVAS POR MERCADO", dataTableOutput("tabla_mercados", height = 520)
                    ),
                    
                    column(width = 6,
                           column(width = 12,
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "CANTIDAD DE MERCADOS", plotlyOutput("graph_mercados_n", height = 200)),
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "MERCADOS ÚNICOS", plotlyOutput("graph_mercados_unicos", height = 230)
                                  )
                           )
                    )
                )
                
            ),
            
            tabItem(
                tabName = "students",
                fluidRow(
                    box(status = "primary", solidHeader = TRUE,
                        title = "PRINCIPALES DESTINOS", plotlyOutput("graph_te_destinos", height = 650)),
                    
                    column(width = 6,
                           column(width = 12,
                                  box(width = NULL, plotlyOutput("graph_te_org", height = 200)),
                                  box(width = NULL, plotlyOutput("graph_te_tipo", height = 200)),
                                  box(width = NULL, plotlyOutput("graph_te_viaje", height = 200))
                                  )
                           )
                    )
                )
                
        )
        )
    
)