library(shiny)
library(shinydashboard)
library(tidyverse)
library(herramientas)
library(comunicacion)
library(DT)
library(treemap)
library(sf)
library(leaflet)
library(htmlwidgets)
library(plotly)


base_agencias <- readRDS("/srv/DataDNMYE/agencias/rlm/base_agencias.rds")

tabla <- read_sf("/srv/DataDNMYE/capas_sig/agencias.gpkg")

destinos_te <- readRDS("/srv/DataDNMYE/agencias/rlm/destinos_te.rds")

turismo_estudiantil <- base_agencias %>% 
  select(realiza_turismo_estudiantil:externo) %>% 
  filter(realiza_turismo_estudiantil=="Si")

receptivas <- format(round(base_agencias %>%
  count(receptivo) %>% 
  mutate(n = n/sum(n)) %>% 
  filter(receptivo == "Si") %>% 
  pull(n),3)*100, decimal.mark = ",")


estudiantil <- base_agencias %>%
  count(realiza_turismo_estudiantil) %>% 
  filter(realiza_turismo_estudiantil == "Si") %>% 
  pull(n)

receptivo <- base_agencias %>%
  count(receptivo) %>% 
  filter(receptivo == "Si") %>% 
  pull(n)

emisivo <- base_agencias %>%
  count(emisivo) %>% 
  filter(emisivo == "Si") %>% 
  pull(n)

interno <- base_agencias %>%
  count(interno_tipo_de_turismo) %>% 
  filter(interno_tipo_de_turismo == "Si") %>% 
  pull(n)


options(DT.options = list(language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')))
