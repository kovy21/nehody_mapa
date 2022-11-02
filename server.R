# libraries
library(leaflet)
library(shiny)
library(shinyjs)
library(htmlwidgets)
library(dplyr)
library(rsconnect)
library(shinycssloaders)
library(shinyWidgets)

#######################################################

# Data
df_acc_sk = read.csv("./data/df_acc_sk.csv", encoding="UTF-8")
df_acc_sk$Dátum = as.Date(df_acc_sk$Dátum,"%d/%m/%Y")

#######################################################

function(input, output) {
  
  filter_data <- eventReactive(input$load, {Sys.sleep(1)
    x <- input$slider
    if(x[2]==2022){
      df_acc_sk[df_acc_sk$Dátum >= as.Date(paste(as.character(x[1]), "-01-01", sep=""))  & 
                  df_acc_sk$Dátum <= as.Date(paste(as.character(x[2]), "-09-30", sep="")),]
    }else{
      df_acc_sk[df_acc_sk$Dátum >= as.Date(paste(as.character(x[1]), "-01-01", sep=""))  & 
                  df_acc_sk$Dátum <= as.Date(paste(as.character(x[2]), "-12-31", sep="")),]
    }
  }, ignoreNULL=FALSE)
  
  observe({output$stats <- renderText({
    paste("Dané obdobie má", 
          dim(filter_data())[1],"nehôd.") 
  })})
  
  output$map <- renderLeaflet({
    leaflet(df_acc_sk, options = leafletOptions(preferCanvas=TRUE,  minZoom = 8)) %>% 
      addTiles() %>%
      # addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 19.65, lat = 48.675, zoom = 8) %>%
      fitBounds(~min(Zemepisná.dĺžka), ~min(Zemepisná.šírka), 
                ~max(Zemepisná.dĺžka), ~max(Zemepisná.šírka)) %>%
      
      addLayersControl(overlayGroups = c("Smrteľné nehody",
                                         "Ťažké nehody",
                                         "Ľahké nehody",
                                         "Nehody bez zranení"), # Clusters
                       options = layersControlOptions(collapsed = FALSE),
                       position = 'topright') %>%
      
      addLegend("bottomright", colors = c("black", "red", "yellow", "green"), 
                labels = c("Smrteľná", "Ťažká", "Ľahká", "Bez zranení"), 
                opacity = 1, title="Typ nehody")
    
    }
  )
  
  observe({
    
    shinyjs::showElement(id = 'loading')
    Sys.sleep(1)
    
    leafletProxy(mapId = "map", data = filter_data()) %>%
      clearMarkers() %>%
      addCircleMarkers(~Zemepisná.dĺžka, ~Zemepisná.šírka,
                       weight = 0.5,
                       col = "black",
                       opacity= 0.7,
                       fillColor = ~ifelse(Usmrtení > 0, "black",
                                           ifelse(Ťažko.zranení>0, "red",
                                                  ifelse(Ľahko.zranení>0, "yellow", "green"))),
                       radius = ~ifelse(Usmrtení > 0, 4, 2.5), 
                       fillOpacity = 0.9, 
                       label = ~ifelse(nchar(Číslo.cesty)>2, 
                                       paste("Cesta II/", Číslo.cesty, ", km: ",
                                             round(Kilometrovníkové.staničenie.dopravnej.nehody, 2),
                                             sep=""), 
                                       ifelse(grepl("R", Číslo.cesty, fixed=TRUE) | grepl("D", Číslo.cesty, fixed=TRUE),
                                              paste("Cesta ", Číslo.cesty, ", km: ",
                                                    round(Kilometrovníkové.staničenie.dopravnej.nehody, 2),
                                                    sep=""), 
                                              paste("Cesta I/", Číslo.cesty, ", km: ",
                                                    round(Kilometrovníkové.staničenie.dopravnej.nehody, 2),
                                                    sep=""))),
                       popup = ~paste("<strong>Dátum</strong>: ", format(Dátum, "%d. %m. %Y"), 
                                      "<br><strong>Čas</strong>: ", Čas, 
                                      "<br><strong>Okres</strong>: ", Okres, 
                                      "<br><strong>Číslo PK</strong>: ", Číslo.cesty, 
                                      "<br><strong>Lokalita</strong>: ", Lokalita.dopravnej.nehody,
                                      "<br><strong>Smerové pomery</strong>: ", Smerové.pomery,
                                      "<br><strong>Druh nehody</strong>: ", Druh.nehody, 
                                      "<br><strong>Počet vozidiel</strong>: ", Počet.zúčastnených.vozidiel,
                                      "<br><strong>Zrážka vozidiel</strong>: ", Zrážka.vozidiel,
                                      "<br><strong>Zavinenie nehody</strong>: ", Zavinenie.nehody,
                                      "<br><strong>Príčina nehody</strong>: ", Hlavná.príčina.nehody,
                                      "<br><strong>Prítomnosť alkoholu</strong>: ", Prítomnosť.alkoholu,
                                      "<br><strong>Usmrtení</strong>: ", Usmrtení,
                                      "<br><strong>Ťažko zranení</strong>: ", Ťažko.zranení,
                                      "<br><strong>Ľahko zranení</strong>: ", Ľahko.zranení,
                                      "<br><strong>Hmotná škoda</strong>: ", Celková.hmotná.škoda, " €",
                                      sep=""),
                       group = ~ifelse(Usmrtení > 0, "Smrteľné nehody", # Úmrtia
                                       ifelse(Ťažko.zranení>0, "Ťažké nehody",
                                              ifelse(Ľahko.zranení>0, "Ľahké nehody", 
                                                     "Nehody bez zranení"))))
    
    
    shinyjs::hideElement(id = 'loading')
    
  }
  )
  
  output$downloadP <- downloadHandler(
    filename = function() {
      paste("nehody-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(filter_data(), 
                file)
    }
  )
  
  output$downloadW <- downloadHandler(
    filename = function() {
      paste("nehody-vsetky-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(df_acc_sk, file)
    }
  )
  
  observeEvent(input$show, {
    showModal(modalDialog(
      title = "Mapa cestnej nehodovosti",
      tagList("Dáta o cestnej nehodovosti sú generované zo štatistiky", 
              a("Ministerstva Vnútra", href="https://www.minv.sk/?kompletna-statistika",
                target="_blank")),
      span("a sú k dispozícii pre roky 2012 - 2022. 
           Nehody sú zverejnené pre cesty I. a II. triedy, 
           rovnako ako aj pre diaľnice a rýchlostné cesty."), br(), br(), 
      span("Keďže sú údaje o zemepisnej šírke a dĺžke vypočítavané dodatočne,
           je možné, že pri ich generácii dochádza k odchýlkam či chybám."), 
      span("Účelom mapy"), strong("nie je"),
      span("presné zobrazenie geografickej polohy dopravných nehôd."), br(), br(),
      tagList("Údaje o cestách sú z databázy", 
              a("Slovenskej Správy Ciest", href="https://www.cdb.sk/sk/statisticke-vystupy.alej",
                target="_blank")),
      tagList("pod licenciou", 
              a("Creative Commons Attribution", href="http://opendefinition.org/licenses/cc-by/",
                target="_blank")),
      easyClose = TRUE,
      footer = "Okno zavrieť kliknutím mimo"
    ))
  })
  
  addResourcePath("nehody_mapa", getwd())
  
  output$frame <- renderUI({
    tags$iframe(style='width:98vw;height:90vh;',
      src="nehody_mapa/data/the_map.html")
  })
  
}
