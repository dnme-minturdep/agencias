
tagList(dashboardPage(
        
    dashboardHeader(title = "AGENCIAS DE VIAJES", titleWidth = 250,
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
            menuItem(tabName = "students", "TURISMO ESTUDIANTIL"),
            menuItem(tabName = "metodo", "METODOLOGÍA")
            
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
                    valueBox(tags$p(style = "font-size: 200%;", as.integer(nrow(base_agencias))),
                             tags$p(style = "font-size: 180%;", "AGENCIAS DE VIAJES EN EL PAÍS"), 
                                 icon = icon("van-shuttle fa-xl", verify_fa = FALSE), width = 8, color = "purple"),
                    
                    valueBox(tags$p(style = "font-size: 200%;", estudiantil), 
                             tags$p(style = "font-size: 180%;","TURISMO ESTUDIANTIL"), 
                             icon = icon("school fa-xl", verify_fa = FALSE), width = 4, color = "blue")
                    ),
                    
                fluidRow(
                    valueBox(tags$p(style = "font-size: 150%;", interno), 
                             tags$p(style = "font-size: 150%;","TURISMO INTERNO"), 
                             icon = icon("car fa-lg", verify_fa = FALSE), width = 4, color = "light-blue"),
                    
                    valueBox(tags$p(style = "font-size: 150%;", internacional), 
                             tags$p(style = "font-size: 150%;","TURISMO INTERNACIONAL"), 
                             icon = icon("globe fa-lg", verify_fa = FALSE), width = 4, color = "olive"),
                    
                    column(width = 4,
                           column(width = 12,
                                  valueBox(tags$p(style = "font-size: 90%;", receptivo),
                                           tags$p(style = "font-size: 120%;", "RECEPTIVAS"), 
                                           icon = icon("plane-arrival fa-sm", verify_fa = FALSE), width = NULL, color = "red"),
                                  
                                  valueBox(tags$p(style = "font-size: 90%;", emisivo), 
                                           tags$p(style = "font-size: 120%;","EMISIVAS"), 
                                           icon = icon("plane-departure fa-sm", verify_fa = FALSE), width = NULL, color = "red"),
                                  
                                  valueBox(tags$p(style = "font-size: 90%;", receptivo_emisivo), 
                                           tags$p(style = "font-size: 120%;","RECEPTIVAS-EMISIVAS"), 
                                           icon = icon("plane fa-sm", verify_fa = FALSE), width = NULL, color = "red")
                                  )
                           )
                        
                    ),
                
                fluidRow(
                    box(width = 12, h4(tags$p(tags$b("Nota: "),"datos actualizados a marzo 2023 en base al Registro de Agencias de Viajes de la Dirección Nacional de Agencias de Viajes.")))
                )
                
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
                    box(width = 12, tags$p(style = "text-align: center; font-size: 20px;","Información de las agencias que operan con clientes no residentes"))
                ),
                fluidRow(
                    box(status = "primary", solidHeader = TRUE,
                        title = "AGENCIAS RECEPTIVAS POR REGIÓN", dataTableOutput("tabla_mercados", height = 520)
                    ),
                    
                    column(width = 6,
                           column(width = 12,
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "CANTIDAD DE REGIONES QUE OPERAN", plotlyOutput("graph_mercados_n", height = 200)),
                                  box(width = NULL, status = "primary", solidHeader = TRUE,
                                      title = "AGENCIAS QUE OPERAN UNA ÚNICA REGIÓN", plotlyOutput("graph_mercados_unicos", height = 230)
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
                ),
            
            tabItem(
                tabName = "metodo",
                
                fluidRow(width = 12,
                         tabPanel('Metodología', 
                                  box(width = NULL,status = "primary", solidHeader = TRUE,
                                      tags$b(style ="text-align: center; font-size: 20px;color:#37BBED;",'Definiciones y conceptos'),
                                      tags$hr(),
                                      p(tags$b('AGENCIAS DE VIAJE EN EL PAÍS:'),' Se incluye en el tablero el universo de agencias de viajes registradas ante la Dirección Nacional de Agencias de Viajes.'),
                                      p(tags$b('AGENCIA DE TURISMO ESTUDIANTIL:'),' Se considera agencia de Turismo Estudiantil a toda aquella agencia que haya obtenido el “CERTIFICADO NACIONAL DE AUTORIZACIÓN PARA AGENCIAS DE TURISMO ESTUDIANTIL” de conformidad con la ley 25.599 de Turismo Estudiantil.'),
                                      p(tags$b('RECEPTIVAS:'),' Se considera como agencias receptivas a todas aquellas que declaren operar destinos Nacionales.'),
                                      p(tags$b('EMISIVAS:'),' Se considera como agencias agencias emisoras a todas aquellas que declaren operar destinos Internacionales.'),
                                      p(tags$b('RECEPTIVAS - EMISIVAS:'),' Agencias que operan con ambas modalidades.'),
                                      p(tags$b('TIPO DE AGENCIA - COMERCIALIZADORA:'),' Agencias de Viajes que, únicamente, celebren contratos de turismo estudiantil por sí y por cuenta y orden del Organizador.'),
                                      p(tags$b('TIPO DE AGENCIA - ORGANIZADORA:'),' Agencias de Viajes que celebren contratos de turismo estudiantil por sí y contraten en forma directa las prestaciones integrantes del paquete turístico.'),
                                      p(tags$b('VIAJE DE EGRESADOS:'),' Refiere a las actividades turísticas realizadas con el objeto de celebrar la finalización de un nivel educativo o carrera, que son organizadas con la participación de los padres o tutores de los alumnos, con propósito de recreación y esparcimiento, ajenos a la propuesta curricular de las escuelas y sin perjuicio del cumplimiento del mínimo de días de clase dispuesto en el calendario escolar de cada jurisdicción educativa.'),
                                      p(tags$b('VIAJE DE ESTUDIOS:'),' Refiere a las actividades formativas integradas a la propuesta curricular de las escuelas, que son organizadas y supervisadas por las autoridades y docentes del respectivo establecimiento.'),
                                      p(tags$b('ORIGEN DE LOS DATOS:'),' Este tablero se realizó en base al Registro Legajo Multipropósito de Agentes de Viaje.')
                                      )))
                )
                
        )
        )
    ),
    tags$footer(includeHTML("/srv/shiny-server/recursos/shiny_footer.html"))
    
)