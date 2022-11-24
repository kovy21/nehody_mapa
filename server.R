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
library(sf)

#######################################################

# Data
df_acc_sk = read.csv("./data/df_acc_sk.csv", encoding="UTF-8")
df_acc_sk$Dátum = as.Date(df_acc_sk$Dátum,"%d/%m/%Y")

geo_all = st_read("./data/geo_all.json")

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
  
  filter_geo_all <- eventReactive(input$load_sec, {Sys.sleep(1)
    y <- input$type_sec
    if(y=="abs"){
      geo_all$col = geo_all$color_raw
      geo_all$lvl = geo_all$stupen_raw
    }else{
      geo_all$col = geo_all$color
      geo_all$lvl = geo_all$stupen
    }
    geo_all
  }, ignoreNULL=FALSE)
  
  observe({output$stats <- renderText({
    paste("Dané obdobie má", 
          dim(filter_data())[1],"nehôd.") 
  })})
  
  output$map <- renderLeaflet({
    leaflet(df_acc_sk, options = leafletOptions(preferCanvas=TRUE,  minZoom = 8)) %>% 
      addTiles() %>%
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
  
  output$sec <- renderLeaflet({
    leaflet(geo_all, options = leafletOptions(preferCanvas=TRUE,  minZoom = 8)) %>% 
      setView(lng = 19.65, lat = 48.675, zoom = 8) %>%
      
      addTiles(group="Zobrazenie OSM")  %>% 
      addProviderTiles(providers$CartoDB.Positron, group="Zobrazenie CartoDB") %>% 
      
      addLayersControl(
        baseGroups = c("Zobrazenie CartoDB", "Zobrazenie OSM"),
        overlayGroups = c("Vysoká nehodovosť",
                          "Nadpriemerná nehodovosť",
                          "Priemerná nehodovosť",
                          "Podpriemerná nehodovosť",
                          "Nízka nehodovosť"), 
        options = layersControlOptions(collapsed = FALSE),
        position = 'topright') %>%
      
      addLegend("bottomright", colors = c("red", "#db7b2b", "#e7b416", "#99c140", "#2dc937"), 
                labels = c("Vysoká",
                           "Nadpriemerná",
                           "Priemerná",
                           "Podpriemerná",
                           "Nízka"), 
                opacity = 1, title="Nehodovosť úseku")   %>%
      
      addPolylines(color=~color_raw, smoothFactor = 2,
                   opacity=~ifelse(road_class=="II.", 0.65, 1),
                   weight=~ifelse(road_class=="II.", 2, 3),
                   label=~road_info,
                   popup = ~paste("<h4>Cesta ", road_info, "</h4>",
                                  "<strong>Nehodovosť úseku: ",  
                                  "<span style='color:", color_raw, ";'>", stupen_raw, "</span>", "</strong>",
                                  "<br><strong>Začiatok úseku</strong>: ", štart, 
                                  "<br><strong>Koniec úseku</strong>: ", koniec, 
                                  "<br><strong>Dĺžka úseku</strong>: ", round(len_km, 2), " km",
                                  "<br><strong>Ťažké nehody</strong>: ", heavy_acc_real, 
                                  "<br><strong>Intenzita dopravy</strong>: ", format(round(rpdi,0), big.mark=" "), " voz. denne",
                                  "<br><strong>Hustota nehôd</strong>: ", round(car_raw,2), " nehôd/km (za rok)", 
                                  sep=""),
                   
                   options=popupOptions(maxWidth=200, keepInView = TRUE),
                   
                   # Highlight section
                   highlight = highlightOptions(
                     weight = 7,
                     fillOpacity = 0.5,
                     fillColor = "white",
                     bringToFront = TRUE,
                     sendToBack = TRUE),
                   
                   group = ~ifelse(stupen_raw == "vysoká", "Vysoká nehodovosť", # Úmrtia
                                   ifelse(stupen_raw == "nadpriemerná", "Nadpriemerná nehodovosť",
                                          ifelse(stupen_raw == "priemerná", "Priemerná nehodovosť", 
                                                 ifelse(stupen_raw == "podpriemerná", "Podpriemerná nehodovosť", 
                                                        "Nízka nehodovosť")))))
      
      }
    )
  
  observe({
    
    shinyjs::showElement(id = 'loading_sec')
    Sys.sleep(1)
    
    leafletProxy(mapId = "sec", data = filter_geo_all()) %>%
      clearShapes() %>%
      addPolylines(color=~col, smoothFactor = 2,
                   opacity=~ifelse(road_class=="II.", 0.65, 1),
                   weight=~ifelse(road_class=="II.", 2, 3),
                   label=~road_info,
                   popup = ~paste("<h4>Cesta ", road_info, "</h4>",
                                  "<strong>Nehodovosť úseku: ",  
                                  "<span style='color:", col, ";'>", lvl, "</span>", "</strong>",
                                  "<br><strong>Začiatok úseku</strong>: ", štart, 
                                  "<br><strong>Koniec úseku</strong>: ", koniec, 
                                  "<br><strong>Dĺžka úseku</strong>: ", round(len_km, 2), " km",
                                  "<br><strong>Ťažké nehody</strong>: ", heavy_acc_real, 
                                  "<br><strong>Intenzita dopravy</strong>: ", format(round(rpdi,0), big.mark=" "), " voz. denne",
                                  "<br><strong>Hustota nehôd</strong>: ", round(car_raw,2), " nehôd/km (za rok)", 
                                  sep=""),
                   
                   options=popupOptions(maxWidth=200, keepInView = TRUE),
                   
                   # Highlight section
                   highlight = highlightOptions(
                     weight = 7,
                     fillOpacity = 0.5,
                     fillColor = "white",
                     bringToFront = TRUE,
                     sendToBack = TRUE),
                   
                   group = ~ifelse(lvl == "vysoká", "Vysoká nehodovosť", # Úmrtia
                                   ifelse(lvl == "nadpriemerná", "Nadpriemerná nehodovosť",
                                          ifelse(lvl == "priemerná", "Priemerná nehodovosť", 
                                                 ifelse(lvl == "podpriemerná", "Podpriemerná nehodovosť", 
                                                        "Nízka nehodovosť")))))
    
    
    shinyjs::hideElement(id = 'loading_sec')
    
  }
  )
  
  observeEvent(input$dwnld, {
    showModal(modalDialog(
      title = "Stiahnuť dáta",
      "Prevziať je možné:",
      tags$ul(
        tags$li(strong("Celý dataset:"),
                paste(dim(df_acc_sk)[1],"nehôd")), 
        tags$li(strong("Aktuálny výber:"), 
                paste(dim(filter_data())[1],"nehôd")),
      ),
      footer = tagList(
        downloadButton(outputId = "downloadW", "Celý dataset"),
        downloadButton(outputId = "downloadP", "Aktuálny výber"),
        modalButton("Zavrieť")
      ),
      easyClose = TRUE
    ))
  })
  
  output$downloadP <- downloadHandler(
    filename = function() {
      paste("nehody-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      on.exit(removeModal()) # Okno sa po stiahnutí zavrie
      write.csv(filter_data(), file)
    }
  )
  
  output$downloadW <- downloadHandler(
    filename = function() {
      paste("nehody-vsetky-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      on.exit(removeModal()) 
      write.csv(df_acc_sk, file)
    }
  )
  
  observeEvent(input$show, {
    showModal(modalDialog(
      title = "Mapa cestnej nehodovosti",
      tagList("Dáta o cestnej nehodovosti sú generované zo štatistiky", 
              a("Ministerstva vnútra", href="https://www.minv.sk/?kompletna-statistika",
                target="_blank")),
      span("a sú k dispozícii pre roky 2012 - 2022. 
           Nehody sú zverejnené pre cesty I. a II. triedy, 
           rovnako ako aj pre diaľnice a rýchlostné cesty."), br(), br(), 
      span("Keďže sú údaje o zemepisnej šírke a dĺžke vypočítavané dodatočne,
           je možné, že pri ich generácii dochádza k odchýlkam či chybám."), 
      span("Účelom mapy"), strong("nie je"),
      span("presné zobrazenie geografickej polohy dopravných nehôd."), br(), br(),
      tagList("Údaje o cestách sú z databázy", 
              a("Slovenskej správy ciest", href="https://www.cdb.sk/sk/statisticke-vystupy.alej",
                target="_blank")),
      tagList("pod licenciou", 
              a("Creative Commons Attribution", href="http://opendefinition.org/licenses/cc-by/",
                target="_blank")),
      tags$hr(),
      tagList("Zdroj:", 
              a("GitHub", href="https://github.com/kovy21/nehody_mapa",
                target="_blank")),
      easyClose = TRUE,
      footer = modalButton("Zavrieť")
    ))
  })
  
  observeEvent(input$sectionshow, {
    showModal(modalDialog(
      title = "Nehodovosť cestných úsekov",
      span("Dáta o nehodovosti cestných úsekov sú vygenerované pre"),
      strong("cesty I. a II. triedy"),
      span("pomocou agregácie počtu dopravných nehôd pre medzikrižovatkové úseky."),
      br(), 
      h4("Absolútna nehodovosť"),
      span("... je určená ako počet ťažkých nehôd na kilometer (za rok) na danom úseku"),
      br(),
      h4("Relatívna nehodovosť"),
      span("... je určená pomocou tzv."), strong("critical accident rate,"),
      tagList("počtu ťažkých dopravných nehôd na danom úseku v pomere k dopravnej intenzite daného úseku. O tejto metrike viac na:", 
              a("SSC", href="https://www.ssc.sk/files/documents/cinnosti/vystavba%20a%20rekonstrukcia/riadenie_bezpecnosti/komplexna_analyza_dn_klasifikacia_knl.pdf",
                target="_blank")),
      br(),
      tags$hr(),
      span("V"), tags$em("oboch"),
      span("prípadoch je zaradenie úseku do jeho kategórie nehodovosti nasledovné:"),
      tags$ul(
        tags$li(strong("Vysoká nehodovosť:", style = "color: red;"), 
                span("Najnehodovejších 0-10 % cestnej siete")), 
        tags$li(strong("Nadpriemerná nehodovosť:", style = "color: #db7b2b;"), 
                span("Najnehodovejších 10-25 % cestnej siete")), 
        tags$li(strong("Priemerná nehodovosť:", style = "color: #e7b416;"), 
                span("Najnehodovejších 25-50 % cestnej siete")), 
        tags$li(strong("Podpriemerná nehodovosť:", style = "color: #99c140;"), 
                span("Najnehodovejších 50-75 % cestnej siete")), 
        tags$li(strong("Nízka nehodovosť:", style = "color: #2dc937;"), 
                span("Zvyšných 25 % cestnej siete"))
      ),
      tagList("Geografické dáta o úsekoch pochádzajú z", 
              a("Celoštátneho sčítania dopravy 2015", 
                href="https://www.ssc.sk/sk/cinnosti/rozvoj-cestnej-siete/dopravne-inzinierstvo.ssc",
                target="_blank"), 
              "od SSC pod licenciou", 
              a("Creative Commons Attribution", 
                href="http://opendefinition.org/licenses/cc-by/", target="_blank")),
      tags$hr(),
      tagList("Zdroj:", 
              a("GitHub", href="https://github.com/kovy21/nehody_mapa",
                target="_blank")),
      easyClose = TRUE,
      footer = modalButton("Zavrieť")
    ))
  })
}
