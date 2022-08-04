dashboardPage(
    
    dashboardHeader(title = "AGENCIAS DE VIAJE",
                    tags$li(a(href = 'https://www.yvera.tur.ar/sinta/',
                              img(src = 'https://tableros.yvera.tur.ar/recursos/logo_sinta.png',
                             height = "30px"),
                              style = "padding-top:10px; padding-bottom:10px;"),
                            class = "dropdown")),
    
    dashboardSidebar(
        sidebarMenu(
            menuItem(tabName = "summary", "RESUMEN"),
            menuItem(tabName = "provinces", "PROVINCIAS"),
            menuItem(tabName = "markets", "RECEPTIVO"),
            menuItem(tabName = "students", "TURISMO ESTUDIANTIL")
        )
    ),
    
    dashboardBody(
        useWaiter(),
        waiter_show_on_load(html = loading_screen, color = "white"),
        useShinyjs(),
        
        tags$head(
            # Include our custom CSS
            includeCSS("styles.css")
        ),
        
        tabItems(
            tabItem(
                tabName = "summary",
                
                fluidRow(
                    valueBox(tags$p(style = "font-size: 300%;", as.integer(nrow(base_agencias))),
                             tags$p(style = "font-size: 180%;", "AGENCIAS DE VIAJE EN EL PAÍS"), 
                                 icon = icon("van-shuttle fa-xl", verify_fa = FALSE), width = 6, color = "purple"),
                    
                    valueBox(tags$p(style = "font-size: 300%;", estudiantil), 
                             tags$p(style = "font-size: 180%;","AGENCIAS DE TURISMO ESTUDIANTIL"), 
                             icon = icon("school fa-xl", verify_fa = FALSE), width = 6, color = "light-blue")
                        ),
                
                fluidRow(
                    valueBox(tags$p(style = "font-size: 200%;", receptivo),
                             tags$p(style = "font-size: 140%;", "AGENCIAS RECEPTIVAS"), 
                             icon = icon("plane-arrival fa-xl", verify_fa = FALSE), width = 4, color = "olive"),
                    
                    valueBox(tags$p(style = "font-size: 200%;", emisivo), 
                             tags$p(style = "font-size: 140%;","AGENCIAS EMISIVAS"), 
                             icon = icon("plane-departure fa-xl", verify_fa = FALSE), width = 4, color = "olive"),
                    
                    valueBox(tags$p(style = "font-size: 200%;", interno), 
                             tags$p(style = "font-size: 140%;","AGENCIAS DE TURISMO INTERNO"), 
                             icon = icon("car fa-xl", verify_fa = FALSE), width = 4, color = "olive")
                ),
                
                br(),
                
               h4("*Datos actualizados a marzo 2022, en base a información de la Dirección Nacional de Agencias de Viaje.")
                
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
                           leafletOutput("mapa_arg", height = 640)
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
                                      title = "CANTIDAD DE MERCADOS QUE OPERAN", plotlyOutput("graph_mercados_n", height = 200)),
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "AGENCIAS QUE OPERAN UN ÚNICO MERCADO", plotlyOutput("graph_mercados_unicos", height = 230)
                                  )
                           )
                    )
                )
                
            ),
            
            tabItem(
                tabName = "students",
                fluidRow(
                    box(status = "primary", solidHeader = TRUE,
                        title = "PRINCIPALES DESTINOS", plotlyOutput("graph_te_destinos", height = 780)),
                    
                    column(width = 6,
                           column(width = 12,
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "TIPO DE AGENCIA", plotlyOutput("graph_te_org", height = 200)),
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "TIPO DE TURISMO", plotlyOutput("graph_te_tipo", height = 200)),
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "TIPO DE VIAJE", plotlyOutput("graph_te_viaje", height = 200))
                                  )
                           )
                    )
                )
                
        )
        )
    
)