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
      menuItem("Uebersicht", tabName = "uebersicht"),
      menuItem("Karten", tabName = "karten")
    )
  ),

  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "uebersicht",
              fluidRow(
                div(class="headers", p("Some text")
              ))),
      # Second tab content
      tabItem(tabName = "karten",
              # Boxes need to be put in a row (or column)
              fluidRow(
                div(class="col-md-6 col-sm-6 col-lg-6", leafletOutput("mymap")),
                div(class="col-md-6 col-sm-6 col-lg-6", leafletOutput("mymap2")),
                div(class="col-md-6 col-sm-6 col-lg-6", dateRangeInput("dateRange", "Date range", start = "01.01.2001", end = "01.01.2017", format = "dd-mm-yyyy", startview = "month", weekstart = 0, language = "en"))
              )
      )
    )
   ))
)