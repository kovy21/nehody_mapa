# libraries
library(leaflet)
library(shiny)
library(shinyjs)
library(htmlwidgets)
library(dplyr)
library(rsconnect)
library(shinycssloaders)
library(shinyWidgets)

# UI ----
navbarPage(
  shinyjs::useShinyjs(),
  title = 'Nehodovosť SR',
  tabPanel("Mapa",  
           
           tags$style(type = "text/css", "html, body {width:100%;height:100%}",
                      HTML("#textt {padding-left:0.75%; padding-right:0.75%; padding-top:0.12%; padding-bottom:0.1%;font-size: 90%;}")),
           
           tags$style('
                #mymap {align: center;
                        margin: -20px;
                        padding: 0px;
                        }'
           ),
           
           tags$div(id = 'mymap', leafletOutput('map', height="92.5vh")),
           
           absolutePanel(top = "50%", left = 20, width = "95%", opacity=0,
                         (column(12,  div(style="display:center-align"),
                                 shinyjs::hidden(div(id = 'loading', style="height:300px;width=300px;",
                                                     addSpinner(div(), spin = "bounce", color = "blue")))))),
           
           fixedPanel(top = "7%", left = "4%", id="controls",
                      opacity = 0.9, draggable = FALSE,
                      
                      sliderInput(
                        "slider",
                        "Dátum:",
                        step=1,
                        min = 2012,
                        max = 2022,
                        value =  c(2020, 2022),
                        sep=""
                      ),
                      
                      actionButton("load", "Načítať dáta")
           ), 
           
           fixedPanel(bottom = "4%", left = "1%", class = "panel panel-default", id="textt",
                      opacity = 0.9,
                      
                      downloadLink(outputId="downloadP", label = textOutput("stats"))),
           
           fixedPanel(bottom = "0%", left = "1%", class = "panel panel-default",
                      opacity = 0,
                      
                      actionButton(inputId = "show", label = "", icon = icon("fa-sharp fa-solid fa-info")), # Disclaimer
                      
                      downloadButton(outputId = "downloadW", label="Stiahnuť všetky dáta")
           )   
         ),
  
  tabPanel("Úseky", 
           absolutePanel(width = "97.5%", height="90%", opacity=0,
                         htmlOutput("frame"))
  )
)