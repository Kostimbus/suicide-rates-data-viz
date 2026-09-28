library(tidyverse)
library(tidyr)
library(rjson)
library(dplyr)

# Helper function to convert underscores to spaces safely
us_to_space <- function(x) gsub("_", " ", as.character(x))

#Data preparation - Suicide rates
rates <- read_csv("WHOMortalityDatabase_Deaths_sex_age_a_country_area_year-Self-inflicted injuries_8th August 2022 04_11.csv") %>%
 filter(age_group != "[0]") %>%
 filter(age_group != "[1-4]") %>%
 filter(age_group != "[5-9]") %>%
 filter(year >= 1990) %>%
 filter(year <= 2019) %>%
 filter(country_name != 'Dominica') %>%
 filter(country_name != 'Saint Kitts and Nevis')

rates["country_name"][rates["country_name"] == "China, Hong Kong SAR"] <- "Hong Kong, China (SAR)"
rates["country_name"][rates["country_name"] == "Republic of Korea"] <- "South Korea"
rates["country_name"][rates["country_name"] == "Serbia"] <- "Republic of Serbia"
rates["country_name"][rates["country_name"] == "Czechia"] <- "Czech Republic"
rates["country_name"][rates["country_name"] == "Russian Federation"] <- "Russia"
rates <- arrange(rates, country_name)

#Data preparation - Human Development Index: from Wide format to Long format
hdi_wide <- read_csv("HDI_HDR.csv")
hdi_wide["country_name"][hdi_wide["country_name"] == "Serbia"] <- "Republic of Serbia"
hdi_wide["country_name"][hdi_wide["country_name"] == "Czechia"] <- "Czech Republic"
hdi_wide["country_name"][hdi_wide["country_name"] == "United States"] <- "United States of America"
hdi_wide["country_name"][hdi_wide["country_name"] == "Korea (Republic of)"] <- "South Korea"
hdi_wide["country_name"][hdi_wide["country_name"] == "Russian Federation"] <- "Russia"
hdi = gather(hdi_wide, year, hdi_index, '1990':'2019', factor_key=TRUE)
hdi <- arrange(hdi, country_name) %>%
 fill(hdi_index, .direction = "down") %>%
 mutate_if(is.factor, ~ as.numeric(as.character(.x)))

#Data preparation - Inequality-adjusted Human Development Index: from Wide format to Long format
ihdi_wide <- read_csv("IHDI_HDR.csv")
ihdi_wide["country_name"][ihdi_wide["country_name"] == "Serbia"] <- "Republic of Serbia"
ihdi_wide["country_name"][ihdi_wide["country_name"] == "Czechia"] <- "Czech Republic"
ihdi_wide["country_name"][ihdi_wide["country_name"] == "United States"] <- "United States of America"
ihdi_wide["country_name"][ihdi_wide["country_name"] == "Korea (Republic of)"] <- "South Korea"
ihdi_wide["country_name"][ihdi_wide["country_name"] == "Russian Federation"] <- "Russia"
ihdi = gather(ihdi_wide, year, ihdi_index, '2010':'2019', factor_key=TRUE)
ihdi <- arrange(ihdi, country_name) %>%
 fill(ihdi_index, .direction = "down") %>%
 mutate_if(is.factor, ~ as.numeric(as.character(.x)))

#Data preparation - GDP PPP: from Wide format to Long format
gdp_ppp_wide <- read_csv("GDP_PPP.csv")
gdp_ppp_wide["country_name"][gdp_ppp_wide["country_name"] == "Serbia"] <- "Republic of Serbia"
gdp_ppp_wide["country_name"][gdp_ppp_wide["country_name"] == "United States"] <- "United States of America"
gdp_ppp_wide["country_name"][gdp_ppp_wide["country_name"] == "Korea, Rep."] <- "South Korea"
gdp_ppp_wide["country_name"][gdp_ppp_wide["country_name"] == "Russian Federation"] <- "Russia"
gdp_ppp_wide["country_name"][gdp_ppp_wide["country_name"] == "Hong Kong SAR, China"] <- "Hong Kong, China (SAR)"
gdp_ppp = gather(gdp_ppp_wide, year, value, '1990':'2020', factor_key=TRUE)
gdp_ppp <- arrange(gdp_ppp, country_name) %>%
 mutate_if(is.factor, ~ as.numeric(as.character(.x)))

#Data preparation for an Overview - general data with HDI, GDP PPP and IHDI (without ages and gender)
rates_overview = rates %>%
 filter(sex == "All") %>%
 filter(age_group == "[All]")

overview_df_hdi = rates_overview %>% 
 left_join(hdi, by=c("country_name", "country_code", "year"))

overview_df_gdp_ppp = rates_overview %>% 
 left_join(gdp_ppp, by=c("country_name", "country_code", "year"))

#IHDI appeared only in 2010 =>
overview_df_ihdi = rates_overview %>% 
 left_join(ihdi, by=c("country_name", "country_code", "year")) %>%
 filter(year >= 2010)
 #na.omit(overview_df)

rates_grouped_by_sex = rates %>%
 filter(age_group == "[All]") %>%
 filter(sex != "Unknown") %>%
 group_by(sex, year) %>%
 summarise_at(.vars = vars(death_rate_per_100k, number, percentage_of_total_deaths), mean, na.rm=TRUE)

#Age Group
rates_grouped_by_age = rates %>%
 filter(age_group != "[All]") %>%
 filter(sex == "All") %>%
 filter(age_group != "[All]") %>%
 group_by(age_group, year) %>%
 summarise_at(.vars = vars(death_rate_per_100k, number, percentage_of_total_deaths), mean, na.rm=TRUE)

#Shape file for Polygon Map
world <- fromJSON(file="world_geojson.json")

#Data for Map Tab
rates_map_sex = rates %>%
 filter(age_group == "[All]") %>%
 filter(sex != "Unknown")

rates_map_age = rates %>%
 filter(age_group != "[All]") %>%
 filter(sex == "All") %>%
 filter(age_group != "[Unknown]")

rates_grouped_by_years <- rates_map_sex %>%
 group_by(country_name) %>% 
 summarise_at(.vars = vars(death_rate_per_100k, number, percentage_of_total_deaths), mean, na.rm=TRUE)

# Datasubset for Input
column_names <- select_if(rates_grouped_by_years, is.numeric)
