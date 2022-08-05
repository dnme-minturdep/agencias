function(input, output) {
    
  
  ### TAB PROVINCIAS
  
  # TABLA POR PROVINCIA
  
  output$tabla_provincias <- renderDataTable(
    
    datatable(extensions = 'Buttons',
              options = list(dom = 'ftp', pageLength = 12, scrollX = T , autoWidth = T),
              rownames = FALSE, caption = htmltools::tags$caption(
                style = 'caption-side: bottom;',
                'Nota: ', htmltools::em(paste0("no se pudo asignar provincia a un ", missing_prov,"% de las agencias debido a la falta de información en los registros, por esto el número de agencias totales no equivale a la suma por provincias."))),
              
              tabla %>% 
                st_set_geometry(NULL) %>% 
                select(1:5) %>% 
                rename(Provincia = provincia, Cantidad = agencias_prov,
                       "% receptivo" = prop_receptivo, "% emisivo" = prop_emisivo,
                       "% interno" = prop_interno)) %>% 
                formatPercentage(c("% receptivo", "% emisivo", "% interno"), digits = 1,
                                 dec.mark = ",")
  )
  
  # MAPA PAÍS
  
  observeEvent(input$tipo_mapa, {
    
    if (input$tipo_mapa == "agencias_prov") {
      tabla <- tabla %>% 
        mutate(hexfill = colorQuantile(palette = "magma", n = 10, reverse = T,
                                     domain = tabla$agencias_prov)(agencias_prov),
               label = paste0("Cantidad: ", agencias_prov))
    } else if (input$tipo_mapa == "prop_receptivo") {
      tabla <- tabla %>% 
        mutate(hexfill = colorQuantile(palette = "magma", n = 10, reverse = T,
                                       domain = tabla$prop_receptivo)(prop_receptivo),
               label = paste0("Agencias receptivas: ", 
                              round(prop_receptivo*100,1), "%"))
    } else if (input$tipo_mapa == "prop_emisivo") {
      tabla <- tabla %>% 
        mutate(hexfill = colorQuantile(palette = "magma", n = 10, reverse = T,
                                       domain = tabla$prop_emisivo)(prop_emisivo),
               label = paste0("Agencias emisivas: ", 
                              round(prop_emisivo*100,1), "%"))
    } else if (input$tipo_mapa == "prop_interno") {
      tabla <- tabla %>% 
        mutate(hexfill = colorQuantile(palette = "magma", n = 10, reverse = T,
                                       domain = tabla$prop_interno)(prop_interno),
               label = paste0("Agencias de turismo interno: ", 
                              round(prop_interno*100,1), "%"))
    }
   

  output$mapa_arg <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      addTiles(urlTemplate = "https://wms.ign.gob.ar/geoserver/gwc/service/tms/1.0.0/mapabase_gris@EPSG%3A3857@png/{z}/{x}/{-y}.png") %>%
      addPolygons(data = tabla,
                  fillColor = ~ hexfill,
                  label = ~ label,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "bold"),
                    textsize = "15px",
                    direction = "auto"),
                  color = "white",
                  fillOpacity = .8, 
                  weight = .5)  %>%
      onRender(
        "function(el, x) {
          L.control.zoom({position:'topright'}).addTo(this);
        }")
      
  })
  
  })
  
  # TABLA MERCADOS
  output$tabla_mercados_prov <- renderDataTable({
    mercados_prov <- base_agencias %>% 
      filter(receptivo=="Si") %>% 
      select(provincia,bolivia:resto_del_mundo) %>% 
      filter(!if_all(bolivia:resto_del_mundo, ~ . == "No"),
             !provincia %in% c("sin informacion","otro lugar"))
    
    agencias_prov <- base_agencias %>% 
      count(provincia,receptivo) %>% 
      filter(receptivo == "Si") %>% 
      rename(total_prov = n) %>% 
      select(provincia, total_prov)
    
    tabla_mercados_prov <- mercados_prov %>% 
      pivot_longer(bolivia:resto_del_mundo) %>% 
      count(provincia,name, value) %>% 
      filter(value == "Si") %>%
      select(-value) %>%
      left_join(agencias_prov) %>% 
      mutate(prop = n/total_prov,
             provincia = toupper(provincia)) %>% 
      pivot_wider(names_from = "name", values_from = c(n,prop)) %>% 
      select(1,2,13:22) 
    
    datatable(extensions = 'Buttons',
              options = list(dom = 'ftp', pageLength = 12, scrollX = T , autoWidth = F),
              rownames = FALSE,
              
              tabla_mercados_prov %>% 
                rename(Provincia = provincia,
                       "Agencias receptivas" = total_prov,
                       "% Bolivia" = prop_bolivia,
                       "% Brasil" = prop_brasil_general,
                       "% Chile" = prop_chile,
                       "% China" = prop_china,
                       "% EE.UU. y Canadá" = prop_ee_uu_y_canada,
                       "% Europa" = prop_europa,
                       "% Paraguay" = prop_paraguay,
                       "% Resto de América" = prop_resto_de_america,
                       "% Resto del Mundo" = prop_resto_del_mundo,
                       "% Uruguay" = prop_uruguay)) %>% 
    formatPercentage(c(3:12), digits = 1,
                     dec.mark = ",")
  }
  )
  
  
  ### TAB MERCADOS
  
  mercados_rec <- {
    turismo_receptivo <- base_agencias %>% 
      filter(receptivo=="Si") %>% 
      select(bolivia:resto_del_mundo)
    
    no_declararon <- as.numeric(base_agencias %>% 
                                  filter(receptivo=="Si") %>% 
                                  count(bolivia, brasil_general, chile, paraguay, uruguay, ee_uu_y_canada,
                                        resto_de_america, europa, china, resto_del_mundo) %>% 
                                  filter(if_all(bolivia:resto_del_mundo, ~ . == "No")) %>% 
                                  pull(n) %>% unique())
    
    declararon <- nrow(turismo_receptivo)-no_declararon
    
    no_declararon <- no_declararon/nrow(turismo_receptivo)
    
    receptivo <- turismo_receptivo %>%
      pivot_longer(bolivia:resto_del_mundo,  names_to = "Tipo", values_to = "Aplica") %>% 
      count(Tipo, Aplica) %>%
      filter(Aplica == "Si") %>% 
      mutate(porcentaje = n/declararon,
             Tipo = str_to_title(Tipo),
             Tipo = case_when(Tipo == "Brasil_general" ~ "Brasil",
                              Tipo == "Resto_del_mundo" ~ "Resto del mundo",
                              Tipo == "Ee_uu_y_canada" ~ "EE.UU. y Canadá",
                              Tipo == "Resto_de_america" ~ "Resto de América",
                              TRUE ~ Tipo)) 
    
    receptivo %>% select(-Aplica) %>% 
      rename(Region = Tipo, Cantidad = n, "%" = porcentaje)
  }
  
  # TABLA AGENCIAS POR MERCADO 
  output$tabla_mercados <- renderDataTable(
    datatable(options = list(dom = 'f', pageLength = 12, scrollX = T , autoWidth = F),
              rownames = FALSE,
              
              mercados_rec) %>% 
      formatPercentage(columns = 3, digits = 1,
                       dec.mark = ",")
  )
  
  mercados_n <- base_agencias %>% 
    filter(receptivo=="Si") %>% 
    select(bolivia:resto_del_mundo) %>% 
    filter(!if_all(bolivia:resto_del_mundo, ~ . == "No")) %>% 
    mutate(count = across(.cols = everything(), .fns = str_count, "Si")) %>%
    rowwise() %>%
    mutate(mercados = across(.cols = contains("count"), .fns = sum)) %>% 
    group_by(mercados) %>% 
    summarise(Cantidad = n(),
              Regiones = as.factor(unique(mercados$count))) 

  
  # GRAFICO AGENCIAS POR CANTIDAD DE MERCADOS
  output$graph_mercados_n <- renderPlotly(
    ggplotly(mercados_n %>% 
      ggplot() +
      geom_col(aes(Regiones, Cantidad), fill = dnmye_colores("purpura")) +
      labs(x = "Cantidad de regiones", y = "") +
      theme(text = element_text(size = 20), 
            axis.title.x = 14) +
      theme_minimal())
  )
  
  mercados_unicos <- base_agencias %>% 
      filter(receptivo=="Si") %>% 
      select(bolivia:resto_del_mundo) %>% 
      filter(!if_all(bolivia:resto_del_mundo, ~ . == "No")) %>% 
      mutate(count = across(.cols = everything(), .fns = str_count, "Si")) %>%
      rowwise() %>%
      mutate(mercados = across(.cols = contains("count"), .fns = sum)) %>% 
      ungroup() %>% 
      filter(mercados == 1) %>% 
      select(bolivia:resto_del_mundo) %>%
      pivot_longer(bolivia:resto_del_mundo) %>% 
      filter(value == "Si") %>% 
      count(name) %>% 
      mutate(participacion = n/sum(n)) %>% 
      arrange(desc(n)) %>% 
      mutate(name = str_to_title(name),
             name = case_when(name == "Brasil_general" ~ "Brasil",
                              name == "Resto_del_mundo" ~ "Resto del mundo",
                              name == "Ee_uu_y_canada" ~ "EE.UU. y Canadá",
                              name == "Resto_de_america" ~ "Resto de América",
                              TRUE ~ name)) %>% 
    rename(Region = name, Cantidad = n)
  
  
  # GRAFICO MERCADOS UNICOS
  output$graph_mercados_unicos <- renderPlotly({
    
    plot_ly(
      data = mercados_unicos,
      type = "treemap",
      values = ~ Cantidad,
      labels = ~ Region,
      parents = NA)
    
  })
  
  
  ### TAB TURISMO ESTUDIANTIL
  
  # GRAFICO DESTINOS
  output$graph_te_destinos <- renderPlotly({
    
    ggplotly(destinos_te %>% 
               head(15) %>% 
               mutate(destinos = toupper(destinos),
                      destinos = fct_reorder(destinos, n)) %>% 
               rename(Destino = destinos, Cantidad = n) %>% 
               ggplot() +
               geom_col(aes(Destino, Cantidad), fill = dnmye_colores("purpura")) +
               labs(x = "", y = "") +
               coord_flip() +
               theme(text = element_text(size = 20)) +
               theme_minimal())
  })
  
  
  # GRAFICO CATEGORIA
  output$graph_te_org <- renderPlotly({
    
    ggplotly(turismo_estudiantil %>%
      select(organizadora,comercializadora) %>% 
      pivot_longer(c(organizadora,comercializadora)) %>% 
      filter(value == "Si") %>% 
      count(name) %>% 
      mutate(porc = n/nrow(turismo_estudiantil),
             name = str_to_title(name)) %>% 
      rename(Cantidad = n,
             Categoria = name) %>% 
      ggplot() +
      geom_col(aes(Categoria, Cantidad), fill = dnmye_colores("rosa")) +
      labs(x = "", y = "") +
      theme(text = element_text(size = 20)) +
      theme_minimal())
  })
  
  
  # GRAFICO TIPO TURISMO
  output$graph_te_tipo <- renderPlotly({
    
    ggplotly(turismo_estudiantil %>%
               pivot_longer(interno_estudiantil:externo, names_to = "Tipo", values_to = "Aplica") %>% 
               count(Tipo, Aplica) %>% 
               mutate(porcentaje = n/nrow(turismo_estudiantil)) %>% 
               filter(Aplica == "Si") %>% 
               mutate(categoria = case_when(Tipo == "externo" ~ "Tipo de turismo",
                                            Tipo == "interno_estudiantil" ~ "Tipo de turismo"),
                      Tipo = case_when(Tipo == "externo" ~ "Externo",
                                       Tipo == "interno_estudiantil" ~ "Interno")) %>% 
               rename(Cantidad = n,
                      Categoria = Tipo) %>% 
               ggplot() +
               geom_col(aes(Categoria, Cantidad), fill = dnmye_colores("azul verde")) +
               labs(x = "", y = "") +
               theme(text = element_text(size = 20)) +
               theme_minimal())
  })
  
  
  # GRAFICO TIPO DE VIAJE 
  output$graph_te_viaje <- renderPlotly({
    
    ggplotly(turismo_estudiantil %>%
               pivot_longer(viaje_de_estudios:viaje_de_egresados, names_to = "Tipo", values_to = "Aplica") %>% 
               count(Tipo, Aplica) %>% 
               mutate(porcentaje = n/nrow(turismo_estudiantil)) %>% 
               filter(Aplica == "Si") %>% 
               mutate(categoria = case_when(Tipo == "viaje_de_egresados" ~ "Tipo de viaje",
                                            Tipo == "viaje_de_estudios" ~ "Tipo de viaje"),
                      Tipo = case_when(Tipo == "viaje_de_egresados" ~ "Viaje de egresados",
                                       Tipo == "viaje_de_estudios" ~ "Viaje de estudios")) %>% 
               rename(Cantidad = n,
                      Categoria = Tipo) %>% 
               ggplot() +
               geom_col(aes(Categoria, Cantidad), fill = dnmye_colores("pera")) +
               labs(x = "", y = "") +
               theme(text = element_text(size = 20)) +
               theme_minimal())
  })
  
  waiter_hide()
  
}
