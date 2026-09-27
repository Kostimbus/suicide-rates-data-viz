# Data Visualization: Suicide Rates and Socioeconomic Factors

This project explores the relationship between global suicide rates and socioeconomic indicators such as the Human Development Index (HDI) and Gross Domestic Product (GDP). It features an interactive web application built with R and Shiny.

## Features
- **Interactive Dashboards**: Visualizes death rates globally and per country based on HDI and GDP (Purchasing Power Parity).
- **Choropleth Maps**: Displays suicide rates by country over time.
- **Trend Analysis**: Line charts detailing rates segmented by age group and gender.
- **Data Tables**: Allows for in-depth data querying and filtering.

## Prerequisites
To run this project locally, you will need:
- [R](https://cran.r-project.org/)
- [RStudio](https://posit.co/download/rstudio-desktop/) (Recommended)

### Required R Packages
Before running the app, ensure you have installed all the necessary dependencies. You can install them by running the following command in your R console:

```R
install.packages(c("shiny", "shinydashboard", "plotly", "tidyverse", "DT", "ggthemes", "tidyr", "rjson", "reshape2", "dplyr"))
```

## How to Run
1. Open the project folder (`Assignment_3`) in RStudio, or open one of the script files (`ui.r`, `server.r`, or `global.r`).
2. RStudio will automatically recognize this as a Shiny application.
3. Click the **"Run App"** button at the top right of the source editor.
4. Alternatively, you can run the app directly from the R console:
```R
shiny::runApp()
```

## Project Structure
- `ui.r` - The user interface configuration of the Shiny app.
- `server.r` - The server-side logic and chart rendering.
- `global.r` - Data preparation, loading, and cleaning steps that run before the app starts.
- `*.csv` and `*.json` - The dataset files containing WHO mortality data, HDI, GDP, and map coordinates.

## Background
This project was initially completed as a university assignment in Data Visualization.
