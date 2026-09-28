library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(shinythemes)

## Left Sidebar ##
sidebar <- dashboardSidebar(
 sidebarMenu(
 menuItem("Overview by HDI, GDP", tabName = "overview", icon = icon("desktop")),
 menuItem("Worldwide", tabName = "worldwide", icon = icon("globe")),
 menuItem("Map", tabName = "map", icon = icon("map")),
 menuItem("Data", tabName = "data", icon = icon("table-cells")),
 menuItem("About", tabName = "about", icon = icon("info"))
 )
)

## Body ##
body <- dashboardBody(
 tabItems(
 ## Overview Tab ##
 tabItem(tabName = "overview",
 ## Row 1 ##
 fluidRow(
 tabBox(height = "600px", width = 12, selected = "HDI",
 ## HDI Tab ##
 tabPanel("HDI", width = 12,
 (box(title = "Slider", width = 9, sliderInput("year_hdi","Select Year",1990,2019,1990,sep = ""))),
 fluidRow(box(title = "Death Rate by HDI", width = 9, plotlyOutput("overview_by_hdi_plot")),
 box(title = "Info", width = 3, 
 " Auf diesem Tab wird die Abhängigkeit zwischen Death Rate und HDI betrachtet. Human Development Index bzw. der Index der menschlichen Entwicklung erschien erst in 1990. Laut der Wiki \"Der HDI berücksichtigt nicht nur das Bruttonationaleinkommen pro Kopf, sondern ebenso die Lebenserwartung und die Dauer der Ausbildung anhand der Anzahl an Schuljahren, die eine 25-jährige Person absolviert hat, sowie der voraussichtlichen Dauer der Ausbildung eines Kindes im Einschulungsalter... Der HDI sollte eine Messung des Entwicklungsstandes ermöglichen, die eher den Bedürfnissen der Menschen entspricht und so viele Aspekte der Entwicklung berücksichtigt, als es einem relativ simplen Index möglich ist.\" \n Dementsprechend bildet HDI das Niveau des Lebens in Ländern ab (mindestens versucht das darzustellen)."))),
 
 ## GDP PPP Tab ##
 tabPanel("GDP PPP", width = 12,
 (box(title = "Slider", width = 9, sliderInput("year_gdp_ppp","Select Year",1990,2019,1990,sep = ""))),
 fluidRow(box(title = "Death Rate by GDP PPP", width = 9, plotlyOutput("overview_by_gdp_ppp_plot")),
 box(title = "Info", width = 3, 
 "Kurze Info über GDP PPP: BIP (KKP) bedeutet Bruttoinlandsprodukt auf Basis der Kaufkraftparität. Dieser Artikel enthält eine Liste von Ländern nach ihrem prognostizierten geschätzten BIP (KKP). Die Länder sind nach BIP (KKP)-Prognoseschätzungen von Finanz- und Statistikinstituten sortiert, die anhand von Markt- oder offiziellen Wechselkursen berechnen. Die auf dieser Seite angegebenen Daten basieren auf dem internationalen Dollar, einer standardisierten Einheit, die von Ökonomen verwendet wird. Bestimmte Regionen, die allgemein nicht als Länder gelten, wie die Europäische Union und Hongkong, werden ebenfalls in der Liste aufgeführt, wenn es sich um unterschiedliche Gerichtsbarkeiten oder wirtschaftliche Einheiten handelt"))),
 
 ## IHDI Tab ##
 tabPanel("IHDI", width = 12,
 (box(title = "Slider", width = 9, sliderInput("year_ihdi","Select Year",2010,2019,2010,sep = ""))),
 fluidRow(box(title = "Death Rate by IHDI", width = 9, plotlyOutput("overview_by_ihdi_plot")),
 box(title = "Info über IHDI", width = 3, 
 "Kurze Info über IHDI aus Wiki: Der Ungleichheitsbereinigte Index der menschlichen Entwicklung (englisch Inequality-adjusted Human Development Index, kurz IHDI) ist ein erweiterter „bereinigter“ Index der menschlichen Entwicklung (HDI: Human Development Index), der die Ungleichheiten innerhalb der einzelnen Länder berücksichtigt. Der IHDI ist ein Indikator für menschliche Entwicklung, der Ungleichheit in Bildung, Gesundheit und Einkommen einschließt. Je größer die Ungleichverteilung, desto niedriger ist der IHDI im Vergleich zum HDI. Beide Indizes werden in jährlichen Reports veröffentlicht vom Entwicklungsprogramm der Vereinten Nationen (UNDP).Der Index erfasst den HDI der Durchschnittspersonen in der Gesellschaft, der geringer ist als der aggregierte HDI, wenn die Verteilung von Gesundheit, Bildung und Einkommen ungleich verteilt ist. Unter vollkommener Gleichheit sind HDI und IHDI gleich; je größer der Unterschied zwischen beiden, desto größer die Ungleichheit. Der IHDI wird für rund 150 Länder geschätzt und erfasst die Verluste in der menschlichen Entwicklung aufgrund der Ungleichheit in Gesundheit, Bildung und Einkommen. Die Unterschiede in allen drei Dimensionen reichen von unter 5 %"))),
 )
 )),
 
 ## Map Tab ##
 tabItem(tabName = "map",
 ## Row 1 ##
 fluidRow(
 box(title = "Variable", width = 6,
 varSelectInput("map_z", "", data = column_names, selected = "death_rate_per_100k")),
 box(title = "Selection:", width = 6,
 selectizeInput("country_age_age", "Select Age Groups", choices = c("All", unique(rates_map_age$age_group)),
 selected = c("[15-19]", "[20-24]", "[25-29]"), multiple = TRUE,
 options = list(plugins = list("remove_button"))))
 ),
 ## Row 2 ##
 fluidRow(
 # Column 1 - Map
 box(title = "Map", width = 6,
 plotlyOutput("map_plot")),
 
 # Column 2 - Line Chart by Age
 box(title="Line Chart by Age", width = 6, plotlyOutput("country_age_line_chart"))
 ),
 fluidRow(
 box(title = "Line Chart by Gender", width = 12,
 plotlyOutput("country_gender_line_chart")))),
 
 ## Worldwide Tab ##
 tabItem(tabName = "worldwide",
 fluidRow(
 tabBox(height = "600px", width = 12, selected = "By Gender",
 ## Gender Tab ##
 tabPanel("By Gender", width = 12,
 (box(title = "Selection", width = 6,
 varSelectInput("world_sex_y", "Select Y-Axis", data = column_names, selected = "death_rate_per_100k"))),
 fluidRow(box(title = "", width = 12, plotlyOutput("worldwide_sex_line_chart")))),
 tabPanel("By Age Group", width = 12,
 fluidRow(
 (box(title = "Selection:", width = 6,
 varSelectInput("world_age_y", "Select Y-Axis", data = column_names, selected = "death_rate_per_100k"))),
 (box(title = "Selection:", width = 6,
 selectizeInput("world_age_age", "Select Age Groups", choices = c("All", unique(rates_grouped_by_age$age_group)),
 selected = c("[15-19]", "[20-24]", "[25-29]"), multiple = TRUE,
 options = list(plugins = list("remove_button")))))),
 fluidRow(box(title = "", width = 12, plotlyOutput("worldwide_age_line_chart"))))))),
 
 tabItem(tabName = "data",
 # Row 1
 fluidRow(
 # Column 1
 box(title = "", width = 12,
 DT::dataTableOutput("rates"))
 ),
 fluidRow(
 # Column 1
 box(title = "", width = 12,
 DT::dataTableOutput("hdi"))
 ))
 )
)

# Put sidebar and body together into a dashboardPage
dashboardPage(
 skin = "black",
 dashboardHeader(title = "Suicide Rates"),
 sidebar,
 body
)
