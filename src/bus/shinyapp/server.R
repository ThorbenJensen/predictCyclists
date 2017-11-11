#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
# Get 
library(httr)
library(jsonlite)
library(lubridate)

#Plot Data
library(dplyr)
library(ggplot2)
library(brms)

#LOAD DATA FROM WEBSERVICE
options(stringsAsFactors = FALSE)

raw.result <- fromJSON("https://services.arcgis.com//OLiydejKCZTGhvWg//ArcGIS//rest//services//Stadtwerke_MS_GTFS_Data_WFL1//FeatureServer//0//query?where=ObjectID%3E%3D0&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token=")

# Auslastungsdata

#LOAD DATA Ein and Ausstiege
hstID = "43901"

# Data for the Auslastung Plot
df <- 
  read.csv(paste0("../../../data/processed/all_" , hstID,  ".csv")) #%>%
  #mutate(timestamp = as.POSIXct(timestamp))

#data for hour and weekday plots
load("../../../results/hourhbf.RData")
load("../../../results/weekdayhbf.RData")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  points <- eventReactive(input$recalc, {
    cbind(as.numeric(raw.result[6]$features$attributes$stop_lon), as.numeric(raw.result[6]$features$attributes$stop_lat))
  }, ignoreNULL = FALSE)
  
  random_points <- eventReactive(input$recalc, {
    cbind(rnorm(40, sd = 0.15) + 7.62571, rnorm(40, sd = 0.15) + 51.96236)
  })
  
  stop_names <- eventReactive(input$recals, {
    raw.result[6]$features$attributes$stop_name}, ignoreNULL = FALSE)
  
  
  output$mymap <- renderLeaflet({
    #First Layer with bus stops and circles with random radiuses
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap.DE,
                       options = providerTileOptions(noWrap = FALSE)
      ) %>%
      addCircles(data = points(), weight = 1,
                 radius = sqrt(rnorm(20, sd = 40) + 8) * 30, popup = stop_names()
      ) %>%
      setView(7.62571, 51.96236, 12,5)
  })
  
  output$mymap2 <- renderLeaflet({
    #Second layer with bus stops and points that get clustered when zoomed out
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap.DE,
                       options = providerTileOptions(noWrap = FALSE)
      ) %>%
      addMarkers(data = points(), clusterOptions = markerClusterOptions(), label = stop_names(),
                 labelOptions = labelOptions(noHide = T, direction = "bottom",
                                             style = list(
                                               "color" = "black",
                                               "font-family" = "serif",
                                               "font-style" = "italic",
                                               "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
                                               "font-size" = "12px",
                                               "text-align" = "center"
                                             ))) %>%
      setView(7.62571, 51.96236, 13,5)
  })
  
  output$abschoepfungBox <- renderValueBox({
    infoBox(
      "Voraussichtliche Abschoepfung", paste0(25), icon = icon("user-o"), color = "orange", fill = TRUE)
  })
  
  output$auslastungBox <- renderValueBox({
    infoBox(
      "Voraussichtliche Auslastung", paste0(25), icon = icon("bus"), color = "blue", fill = TRUE)
  })
  
  output$reichweiteBox <- renderValueBox({
    infoBox(
      "Taegliche Displayreichweite", paste0(25), icon = icon("eye"), color = "yellow", fill = TRUE)
  })
  
  output$radaufkommenBox <- renderValueBox({
    infoBox(
      "Allgemeines Radaufkommen", paste0(25), icon = icon("bicycle"), color = "green", fill = TRUE)
  })
  
  output$einstiegeBox <- renderValueBox({
    infoBox(
      "Einstiege", paste0(25), icon = icon("arrow-up"), color = "olive", fill = TRUE)
  })
  
  output$ausstiegeBox <- renderValueBox({
    infoBox(
      "Ausstiege", paste0(25), icon = icon("arrow-down"), color = "maroon", fill = TRUE)
  })
  
  output$auslastungPlot <- renderPlot({
    
    df %>%
      #filter(hour > 4 & hour < 10) %>% # morning
      # filter(hour > 15 & hour < 21) %>% # afternoon
      ggplot(data = .) +
      geom_histogram(position = "dodge", aes(x = Ein, fill = "Einstiege"), alpha = 0.75, binwidth = 1) + 
      geom_histogram(position = "dodge", aes(x = Aus, fill = "Ausstiege"), alpha = 0.75, binwidth = 1) +
      labs(title = "Ein- und Ausstiege", x = "Anzahl Ein- / Ausstiege", y = "Häufigkeit im Zeitraum", fill = "Legende") +
      theme_light()
    
  })
  
  output$hourPlot <- renderPlot({
    plot(marginal_effects(hourm), points = F, plot = F)[[1]] + 
      labs(title = "", x = "Stunde", y = "Einstiege") + 
      scale_x_continuous(breaks = 7:22) + 
      coord_cartesian(ylim = 0:18) +
      scale_y_continuous(breaks = seq(0, 18, by = 2)) + 
      theme_light(base_size = 16) # change to whatever looks best
  })
  
  output$weekdayPlot <- renderPlot({
    plot(marginal_effects(weekdaym), points = F, plot = F)[[1]] + 
      labs(title = "", x = "Wochentag", y = "Einstiege") + 
      # scale_x_continuous(breaks = 7:22) + 
      coord_cartesian(ylim = 0:18) +
      scale_y_continuous(breaks = seq(0, 18, by = 2)) + 
      theme_light(base_size = 16) # change to whatever looks best
  })
})