# libraries
library(leaflet)
library(shiny)
library(shinyjs)
library(htmlwidgets)
library(htmltools)
library(dplyr)
library(rsconnect)
library(shinycssloaders)
library(shinyWidgets)

# UI
navbarPage(
  shinyjs::useShinyjs(),
  title = 'Nehodovosť SR',
  tabPanel("Nehody",  
           
           tags$style(type = "text/css", "html, body {width:100%;height:100%}",
                      HTML("#textt {padding-left:0.75%; padding-right:0.75%; padding-top:0.12%; padding-bottom:0.1%;font-size: 90%;}")),
           
           tags$style('
                #mymap {align: center;
                        margin-top: -1.5%;
                        margin-bottom: -1%;
                        margin-right: -1%;
                        margin-left: -1%;
                        }'
           ), 
           
           tags$div(id = 'mymap', leafletOutput('map', height="94vh")),
           
           absolutePanel(top = "50%", left = 20, width = "95%", opacity=0,
                         (column(12,  div(style="display:center-align"),
                                 shinyjs::hidden(div(id = 'loading', style="height:300px;width=300px;",
                                                     addSpinner(div(), spin = "bounce", color = "blue")))))),
           
           fixedPanel(top = "7%", left = "4%", id="controls",
                      opacity = 0.9, draggable = FALSE,
                      
                      sliderInput(
                        "slider",
                        "Rok:",
                        step=1,
                        min = 2012,
                        max = 2022,
                        value =  c(2020, 2022),
                        sep=""
                      ),
                      
                      actionButton("load", "Načítať dáta")
           ), 
           
           fixedPanel(bottom = "0%", left = "1%", class = "panel panel-default",
                      opacity = 0,
                      
                      actionButton(inputId = "show", label = "", icon = icon("fa-sharp fa-solid fa-info")), # Disclaimer
                      
                      actionButton(inputId = "dwnld", label="Stiahnuť dáta", icon = icon("fa-sharp fa-solid fa-download"))
           )   
         ),
  
  tabPanel("Úseky (I. a II. trieda)",  
           
           tags$style(type = "text/css", "html, body {width:100%;height:100%}",
                      HTML("#textt {padding-left:0.75%; padding-right:0.75%; padding-top:0.12%; padding-bottom:0.1%;font-size: 90%;}")),
           
           tags$div(id = 'mymap', leafletOutput('sec', height="94.25vh")),
           
           fixedPanel(top = "7%", left = "4%", id="controls",
                      opacity = 0.9, draggable = FALSE,
                      
                      selectInput("type_sec", "Metodika:",
                                  c("Absolútna nehodovosť" = "abs",
                                    "Relatívna nehodovosť" = "rel"),
                                  selected="abs"),
                      
                      actionButton("load_sec", "Prepočítať")
           ), 
           
           absolutePanel(top = "50%", left = 20, width = "95%", opacity=0,
                         (column(12,  div(style="display:center-align"),
                                 shinyjs::hidden(div(id = 'loading_sec', style="height:300px;width=300px;",
                                                     addSpinner(div(), spin = "bounce", color = "blue")))))),
           
           fixedPanel(bottom="0%", left = "1.25%", class = "panel panel-default",
                      opacity = 0,
                      
                      actionButton(inputId = "sectionshow", label = "", icon = icon("fa-sharp fa-solid fa-info"))
           )
           
  )
)
