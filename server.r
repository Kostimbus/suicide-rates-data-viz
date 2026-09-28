library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(DT)
library(ggthemes)

options(scipen=999)
theme_set(theme_bw())

# Helper function to convert underscores to spaces safely
us_to_space <- function(x) gsub("_", " ", as.character(x))

# You can set your Mapbox token via environment variable or replace the placeholder below
Sys.setenv('MAPBOX_TOKEN' = Sys.getenv('MAPBOX_TOKEN', 'YOUR_MAPBOX_TOKEN_HERE'))

shinyServer(function(input, output) {
 
 # Slider Inputs
 # HDI
 overview_filtered_hdi <- reactive({
 overview_df_f <- overview_df_hdi %>%
 filter(year==input$year_hdi)
 overview_df_f
 })
 
 # GDP PPP
 overview_filtered_gdp_ppp <- reactive({
 overview_df_f <- overview_df_gdp_ppp %>%
 filter(year==input$year_gdp_ppp)
 overview_df_f
 })
 
 # IHDI
 overview_filtered_ihdi <- reactive({
 overview_df_f <- overview_df_ihdi %>%
 filter(year==input$year_ihdi)
 overview_df_f
 })
 
 # Age-Group Worldwide
 rates_age_worldwide <- reactive({
 rates_age_worldwide_f <- rates_grouped_by_age
 if (!"All" %in% input$world_age_age) {
 rates_age_worldwide_f <- rates_age_worldwide_f %>%
 filter(age_group %in% input$world_age_age)
 }
 rates_age_worldwide_f
 })
 
 # Age-Group Country
 rates_age_country <- reactive({
 rates_age_country_f <- rates_map_age
 if (!"All" %in% input$country_age_age) {
 rates_age_country_f <- rates_age_country_f %>%
 filter(age_group %in% input$country_age_age)
 }
 rates_age_country_f
 })
 
 ## Bubble Chart: HDI ##
 output$overview_by_hdi_plot <- renderPlotly({
 p <- ggplot(data = overview_filtered_hdi()) + 
 geom_point(alpha = 0.5, mapping = aes(x = hdi_index, y = death_rate_per_100k,
 text = str_c("Country: ", country_name, "\nDeath Rate per 100k: ", format(round(death_rate_per_100k, 2), nsmall = 2), "\nTotal: ", number),
 size = hdi_rank_2019, color = region_name)) +
 geom_smooth(mapping = aes(x = hdi_index, y = death_rate_per_100k), method = "glm") + 
 scale_size(range = c(1, 6), trans = 'reverse') + 
 labs(
 title = "Death Rate by HDI",
 x = "Human Development Index",
 y = "Death Rate per 100k",
 color = "Regions",
 caption = "Size: HDI Rank 2019",
 size = ""
 ) +
 xlim(0.5,1) + 
 theme(axis.title=element_text(size=12)) + 
 theme(plot.caption.position = "plot",
 plot.caption = element_text(hjust = 0))
 
 ggplotly(p, tooltip = "text")
 })
 
 ## Bubble Chart: GDP PPP ##
 output$overview_by_gdp_ppp_plot <- renderPlotly({
 p <- ggplot(data = overview_filtered_gdp_ppp()) + 
 geom_point(mapping = aes(x = value, y = death_rate_per_100k,
 text = str_c("Country: ", country_name, "\nDeath Rate per 100k: ", format(round(death_rate_per_100k, 2), nsmall = 2), "\nTotal: ", number),
 size = value, color = region_name)) + 
 scale_size(range = c(1, 6)) + 
 labs(
 title = "Death Rate by GDP PPP",
 x = "Gross Domestic Product based on Purchasing Power Parity",
 y = "Death Rate per 100k",
 color = "Regions",
 caption = "Size: GDP PPP Value",
 size = ""
 ) +
 scale_x_log10(breaks = c(1000000000, 10000000000, 100000000000, 1000000000000, 10000000000000),
 labels = c("1 B", "10B", "100 B", "1 T", "10 T")) + 
 theme(axis.title=element_text(size=12)) + 
 theme(plot.caption.position = "plot",
 plot.caption = element_text(hjust = 0))
 
 ggplotly(p, tooltip = "text")
 })
 
 ## Bubble Chart: IHDI ##
 output$overview_by_ihdi_plot <- renderPlotly({
 p <- ggplot(data = overview_filtered_ihdi()) + 
 geom_point(alpha = 0.5, mapping = aes(x = ihdi_index, y = death_rate_per_100k,
 text = str_c("Country: ", country_name, "\nDeath Rate per 100k: ", format(round(death_rate_per_100k, 2), nsmall = 2), "\nTotal: ", number),
 color = region_name)) + 
 geom_smooth(mapping = aes(x = ihdi_index, y = death_rate_per_100k)) + 
 labs(
 title = "Death Rate by IHDI",
 x = "Inequality-adjusted Human Development Index",
 y = "Death Rate per 100k",
 color = "Regions",
 size = ""
 ) +
 xlim(0.5,1) + 
 theme(axis.title=element_text(size=12)) + 
 theme(plot.caption.position = "plot",
 plot.caption = element_text(hjust = 0))
 
 ggplotly(p, tooltip = "text")
 })
 
 ## Map Plot ##
 output$map_plot <- renderPlotly({
 plot_mapbox() %>%
 layout(mapbox = list(style = "carto-positron", center = list(lon = 7.46, lat = 51.51), zoom = 1),
 title = "Death Rate by Countries 1990-2019") %>% 
 add_trace(
 type = "choroplethmapbox",
 geojson = world,
 featureidkey = "properties.admin",
 locations = rates_grouped_by_years$country_name,
 z = rates_grouped_by_years[[as.character(input$map_z)]],
 colorscale = "Viridis"
 )
 })
 
 ## Line Chart: Gender ##
 output$country_gender_line_chart <- renderPlotly({
 idx <- ifelse(is_null(event_data("plotly_click")$pointNumber), 84, event_data("plotly_click")$pointNumber + 1)
 country <- rates_grouped_by_years[[idx, 1]]
 
 rates_map_sex_f <- rates_map_sex %>% 
 filter(country_name == country)
 
 p <- ggplot(data = rates_map_sex_f) +
 geom_line(mapping = aes(x = year, y = !!input$map_z, color = sex)) +
 geom_point(mapping = aes(x = year, y = !!input$map_z, color = sex, size = 0.5,
 text = str_c("Death Rate per 100k: ", format(round(!!input$map_z, 2), nsmall = 2), "\nYear: ", year))) +
 scale_x_continuous() +
 theme(legend.position = "top") +
 labs(
 title = str_c("By Gender, ", country),
 x = "Year",
 y = toupper(us_to_space(input$map_z)),
 color = "Gender",
 size = ""
 )
 
 ggplotly(p, tooltip="text")
 })
 
 ## Line Chart: Age ##
 output$country_age_line_chart <- renderPlotly({
 idx <- ifelse(is_null(event_data("plotly_click")$pointNumber), 84, event_data("plotly_click")$pointNumber + 1)
 country <- rates_grouped_by_years[[idx, 1]]
 
 rates_map_age_f <- rates_age_country() %>% 
 filter(country_name == country)
 
 p <- ggplot(data = rates_map_age_f) +
 geom_line(mapping = aes(x = year, y = !!input$map_z, color = age_group, linetype = age_group)) +
 geom_point(mapping = aes(x = year, y = !!input$map_z, color = age_group, size = 0.1,
 text = str_c("Death Rate per 100k: ", format(round(!!input$map_z, 2), nsmall = 2), "\nYear: ", year, "\nAge: ", age_group))) +
 scale_x_continuous() +
 theme(legend.position = "top") +
 labs(
 title = str_c("By Age Group, ", country),
 x = "Year",
 y = toupper(us_to_space(input$map_z)),
 color = "Age Group",
 size = ""
 )
 
 ggplotly(p, tooltip="text")
 })
 
 ## Line Chart: Worldwide-Sex ##
 output$worldwide_sex_line_chart <- renderPlotly({
 p <- ggplot(data = rates_grouped_by_sex) +
 geom_line(mapping = aes(x = year, y = !!input$world_sex_y, color = sex)) +
 geom_point(mapping = aes(x = year, y = !!input$world_sex_y, color = sex, size = 0.5,
 text = str_c(toupper(us_to_space(input$world_sex_y)), ": ", format(round(!!input$world_sex_y, 2), nsmall = 2), "\nYear: ", year))) +
 scale_x_continuous() +
 theme(legend.position = "top") +
 labs(
 title = "By Gender, Worldwide ",
 x = "Year",
 y = toupper(us_to_space(input$world_sex_y)),
 color = "Gender",
 size = ""
 )
 
 ggplotly(p, tooltip="text")
 })
 
 ## Line Chart: Worldwide-Age ##
 output$worldwide_age_line_chart <- renderPlotly({
 p <- ggplot(data = rates_age_worldwide()) +
 geom_line(mapping = aes(x = year, y = !!input$world_age_y, color = age_group)) +
 geom_point(mapping = aes(x = year, y = !!input$world_age_y, color = age_group, size = 0.1,
 text = str_c(toupper(us_to_space(input$world_age_y)), ": ", format(round(!!input$world_age_y, 2), nsmall = 2), "\nYear: ", year))) +
 scale_x_continuous() +
 theme(legend.position = "top") +
 labs(
 title = "By Age Group, Worldwide ",
 x = "Year",
 y = toupper(us_to_space(input$world_age_y)),
 color = "Age Group",
 size = ""
 )
 
 ggplotly(p, tooltip="text")
 })
 
 ## Data Tab##
 output$rates <- DT::renderDataTable({
 DT::datatable(rates[, c("region_name", "country_name", "year", "sex", "age_group", "number", "death_rate_per_100k", "percentage_of_total_deaths"), drop = FALSE], filter = 'top')
 })
 
 output$hdi <- DT::renderDataTable({
 DT::datatable(hdi[, c("country_name", "hdi_code", "hdi_rank_2019", "year", "hdi_index"), drop = FALSE], filter = 'top')
 })
 
})
