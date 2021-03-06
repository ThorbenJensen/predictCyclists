#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library(leaflet)
library(shinydashboard)
# Define UI for application that draws a histogram
shinyUI(dashboardPage(skin="black",
  
  
  dashboardHeader(
    title = "Bus Factor"
    ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Übersicht", tabName = "uebersicht"),
      menuItem("Karten", tabName = "karten")
    )
  ),

  dashboardBody(
    
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styling.css")
    ),
    
    tabItems(
      # First tab content
      tabItem(tabName = "uebersicht",
              fluidRow(
                box(
                  title = "Prognosen", width = 12, solidHeader = TRUE,
                  div(class="col-sm-6 col-md-6 col-lg-6", valueBoxOutput("abschoepfungBox")),
                  div(class="col-sm-6 col-md-6 col-lg-6", valueBoxOutput("auslastungBox")),
                  div(class="col-sm-6 col-md-6 col-lg-6", valueBoxOutput("reichweiteBox")),
                  div(class="col-sm-6 col-md-6 col-lg-6", valueBoxOutput("radaufkommenBox"))
                ),
                box(
                  title = "Einstellungen", width = 6, solidHeader = TRUE, status = "primary",
                  sliderInput("uhrzeit1", "Uhrzeit:", min = 0, max = 24, value = c(6, 22)),
                  dateRangeInput("datum1", "Datum:", start = "2017-10-01", end = "2017-10-31", format = "dd-mm-yyyy", startview = "month", weekstart = 0, language = "de"),
                  textInput("haltestelle", " Haltestelle", value = " Hauptbahnhof"),
                  box(
                    title = "Wetter", width = 12, solidHeader = TRUE,
                    checkboxGroupInput("wetter", "Datenbankinformationen:",
                                       choiceNames =
                                         list(icon("cloud"), icon("thermometer"),
                                              icon("grav"), icon("smile-o")),
                                       choiceValues =
                                         list("Regen", "Temperatur", "Feiertage", "Send")
                    )
                  )
                ),
                box(
                  title = "Durchschnittliche Auslastung", width = 6, solidHeader = TRUE, status = "warning",
                  valueBoxOutput("einstiegeBox"),
                  valueBoxOutput("ausstiegeBox"),
                  box(
                    title = "Hauptbahnhof", width = 12, solidHeader = TRUE,
                    plotOutput(outputId = "auslastungPlot")
                  )
                  
                ),
                
                box(
                  title = "", width = 12, solidHeader = TRUE,
                  box(
                    title = "Hauptbahnhof, Tagesverlauf Einstiege, März 2017, Modellverlauf", width = 6, solidHeader = TRUE,
                    plotOutput(outputId = "hourPlot")
                  ),
                  box(
                    title = "Hauptbahnhof, Wochenverlauf Einstiege, März 2017, Modellverlauf", width = 6, solidHeader = TRUE,
                    plotOutput(outputId = "weekdayPlot")
                  )),
                box(
                  title = "Vergleiche Einstiege - Prognose 08-11-2017", width = 8, solidHeader = TRUE,
                  tags$img(src = "forecasts.png", width = "100%", height = "100%")
                ), 
                box(
                  title = "Güte Prognose", width = 4, solidHeader = TRUE,
                  tags$img(src = "guete.png", width = "100%", height = "100%")
                )
                
              )),
      # Second tab content
      tabItem(tabName = "karten",
              # Boxes need to be put in a row (or column)
              fluidRow(
                box(
                  title = "Einstellungen", width = 12, solidHeader = TRUE, status = "primary",
                  sliderInput("uhrzeit2", "Uhrzeit:", min = 0, max = 24, value = Sys.time()),
                  dateInput("datum2", "Datum:", value = Sys.time(), format = "dd-mm-yyyy", startview = "month", weekstart = 0, language = "de"),
                  radioButtons("ein_aus", "Auslastung von:", c("Einstiege" = "ein", "Ausstiege" = "aus"))
                ),
                
                box(
                  title = "Auslastungskarte", width = 6, solidHeader = TRUE, status = "success",
                  leafletOutput("mymap")
                ),
                
                box(
                  title = "Haltestellen", width = 6, solidHeader = TRUE, status = "success",
                  leafletOutput("mymap2")
                )
                
                # div(class="col-md-6 col-sm-6 col-lg-6", dateRangeInput("dateRange", "Date range", start = "01.01.2001", end = "01.01.2017", format = "dd-mm-yyyy", startview = "month", weekstart = 0, language = "en"))
              )
      )
    )
  ))
)