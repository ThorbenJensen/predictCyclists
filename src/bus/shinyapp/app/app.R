library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

# Get 
library(httr)
library(jsonlite)
library(lubridate)

options(stringsAsFactors = FALSE)

raw.result <- fromJSON("https://services.arcgis.com//OLiydejKCZTGhvWg//ArcGIS//rest//services//Stadtwerke_MS_GTFS_Data_WFL1//FeatureServer//0//query?where=ObjectID%3E%3D0&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token=")


ui <- fluidPage(
  
  tags$link(rel = "stylesheet", type = "text/css", href = "styling.css"),
  
  tags$style(type="text/css", "#mymap, #mymap2 { height: calc(100vh - 80px); padding: 50px; margin-bottom: 20px;}"),
  leafletOutput("mymap"),
  leafletOutput("mymap2"),
  p(),
  actionButton("recalc", "New points"),
  dateRangeInput("dateRange", "Date range", start = "01.01.2001", end = "01.01.2017", format = "dd-mm-yyyy", startview = "month", weekstart = 0, language = "en")
)

server <- function(input, output, session) {
  
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
      setView(7.62571, 51.96236, 13,5)
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
}



shinyApp(ui, server)
