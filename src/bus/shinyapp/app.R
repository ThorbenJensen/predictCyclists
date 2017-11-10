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
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points"),
  actionButton("clear", "Clear shapes")
)

server <- function(input, output, session) {
  
  points <- eventReactive(input$recalc, {
    cbind(as.numeric(raw.result[6]$features$attributes$stop_lon), as.numeric(raw.result[6]$features$attributes$stop_lat))
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    #First Layer with random points
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap.DE,
                       options = providerTileOptions(noWrap = FALSE)
      ) %>%
      addMarkers(data = points(), clusterOptions = markerClusterOptions()) %>%
      setView(7.62571, 51.96236, 13,5)
  })
}



shinyApp(ui, server)