library(shiny)
library(tidyverse)
library(naniar)
library(janitor)
library(shinythemes)

species_map <- list("Long Eared Owl" = c("Asio","otus"),
                    "Great Spotted Cuckoo" = c("Clamator","glandarius"),
                    "Streaked Weaver" = c("Ploceus","manyar"),
                    "Red legged partridge" = c("Alectoris","rufa"),
                    "Mandarin Duck" = c("Aix","galericulata"))

ui <- fluidPage(
  theme = shinytheme("superhero"),
  titlePanel("Sex Specific Contributions to Nest Building"),
  
  tabsetPanel(
    tabPanel("Intro",
             fluidRow(
               column(12,
                      shiny::tags$div(
                        style = "padding: 10px;",
                        h4("Introduction"),
                        p("Welcome to Group 14’s final project for BIS15L in Winter 2024. Our study focuses on Sex Specific Contributions to Nest Building in birds, exploring various factors correlated with these contributions."),
                        p("Our Dataset consists of 521 observations with 8 features, including:"),
                        shiny::tags$ul(
                          shiny::tags$li("Species: The species of bird"),
                          shiny::tags$li("Nest Builder (Sex): The sex of the bird responsible for nest building"),
                          shiny::tags$li("Nest Site: The location where the nest is built"),
                          shiny::tags$li("Nest Structure: The physical structure of the nest"),
                          shiny::tags$li("Clutch Size Mean: The average size of the clutch (number of eggs)"),
                          shiny::tags$li("Incubating Sex: The sex of the bird responsible for incubating the eggs"),
                          shiny::tags$li("Length of Breeding Season: The duration of the breeding season"),
                          shiny::tags$li("Latitude Mean: The average latitude of the bird's habitat")
                        ),
                        hr(),
                        h4("Nest Builder Distribution In Our Dataset"),
                        tableOutput("nest_builder_table"),
                        hr(),
                        p("Authors: Amina Muhic, Layla Abedinimehr, Meghana Manepalli, Valerie Whitfield")
                      )
               )
             )
    ),
    tabPanel("Plots",
             sidebarLayout(
               sidebarPanel(
                 selectInput("master_input", "Select Plot Type",
                             choices = c("Distribution of Categorical Variables by Nest Builder Sex", 
                                         "Distribution of Nest Builder by Sex Against Continuous Variables",
                                         "Trends in Breeding Season Length (and Other Continuous Variables)",
                                         "Differences Between Variables Across Different Genuses")
                 ),
                 uiOutput("additional_inputs")
               ),
               mainPanel(
                 plotOutput("plot")
               )
             )
    ),
    tabPanel("Summary",
             fluidRow(
               column(12,
                      shiny::tags$div(
                        style = "padding: 10px;",
                        h4("Predictions"),
                        shiny::tags$ul(
                          shiny::tags$li("In species breeding at higher latitudes and in species with shorter breeding seasons, nests are more likely to be built by both parents. Higher latitude, shorter breeding season = more seasonally available food, rapid nest building; both parents expected to contribute."),
                          shiny::tags$li("In species with larger clutch sizes and in species where females incubate the eggs, nests are more likely to be built by the male parent. Trade-off for the female’s large contribution/investment to reproductive efforts."),
                          shiny::tags$li("Nests that are above ground and more complex in structure are more likely to be built by both parents. Both parents building = combined effort/cognitive abilities.")
                        ),
                      )
               ),
               column(12,
                      shiny::tags$div(
                        style = "padding: 10px;",
                        h4("Findings"),
                        shiny::tags$ul(
                          shiny::tags$li("We actually tend to see a slight tendency towards single parent nest builders over biparental nest building at high latitudes."),
                          shiny::tags$li("Breeding season length seems to have no impact on sex of the nest builder."),
                          shiny::tags$li("With species that have female incubators and large clutch sizes, we still see female nest builders."),
                          shiny::tags$li("Above-ground, complex nests tend to be built by both parents."),
                          shiny::tags$li("Overall, most nests tend to built by females, then both parents, followed by neither parent, and finally the male parent.")
                        )
                      )
               )
             )
    ),
    tabPanel("Birds Spotlight",
             sidebarLayout(
               sidebarPanel(
                 radioButtons("bird_selection","Select Bird:",
                              choices = c("Long Eared Owl", "Great Spotted Cuckoo", "Streaked Weaver", "Red legged partridge", "Mandarin Duck"))
               ),
               mainPanel(
                 tableOutput("bird_data_table"),
                 br(),
                 div(
                   htmlOutput("bird_image")
                 ),
                 br(),
                 uiOutput("bird_facts")
               )
             )
    ),
    tabPanel("References",
             fluidRow(
               column(12,
                      shiny::tags$div(
                        style = "padding: 10px;",
                        h4("References"),
                        p("Mark C Mainwaring, Jenő Nagy, Mark E Hauber, Sex-specific contributions to nest building in birds, Behavioral Ecology, Volume 32, Issue 6, November/December 2021, Pages 1075–1085"),
                        p(a(href = "https://datadryad.org/stash/dataset/doi:10.5061/dryad.vhhmgqnsq", target = "_blank", "https://datadryad.org/stash/dataset/doi:10.5061/dryad.vhhmgqnsq"))
                      )
               )
             )
    )
  )
)


server <- function(input, output, session) {
  species_map <- list("Long Eared Owl" = c("Asio","otus"),
                      "Great Spotted Cuckoo" = c("Clamator","glandarius"),
                      "Streaked Weaver" = c("Ploceus","manyar"),
                      "Red legged partridge" = c("Alectoris","rufa"),
                      "Mandarin Duck" = c("Aix","galericulata"))
  
  

  dataset <- read_delim("https://raw.githubusercontent.com/meghana202/BIS15W2024_Group14/main/data/Sex_specific_contribution.csv", delim=";") %>% clean_names()
  dataset <- dataset %>% separate(species, into= c("genus", "species"), sep = "_")
  large_genuses_data <- dataset %>% 
    group_by(genus) %>% 
    summarize(n_species=n()) %>% 
    arrange(desc(n_species)) %>% 
    slice_head(n=35)
  large_genuses <- large_genuses_data$genus
  
  observeEvent(input$bird_selection, {
    genus_bird <- species_map[[input$bird_selection]][1]
    species_bird <- species_map[[input$bird_selection]][2]
    bird_data <- dataset %>% filter(genus == genus_bird, species == species_bird)
    
    print(genus_bird)
    print(species_bird)
    
    output$bird_data_table <- renderTable({
      bird_data
    })
    
    output$bird_image <- renderUI({
      url <- paste('https://raw.githubusercontent.com/meghana202/BIS15W2024_Group14/main/images/', genus_bird, "_", species_bird, ".jpg", sep='')
      list(
        tags$img(src = url, width = "auto", height = 400, alt = paste("Image for", input$bird_selection))
      )
    })
    
    output$bird_facts <- renderUI({
      facts <- switch(input$bird_selection,
                      "Long Eared Owl" = c("Females incubate, and neither sex builds the nest.",
                                           "Owls do not build their own nest, this species usually uses nests built by other animals"),
                      "Great Spotted Cuckoo" = c("Neither gender incubates the eggs nor builds the nest.",
                                                 "They are brood parasites- species that lays its eggs in the nests of other bird species, relying on them to incubate and raise its offspring."),
                      "Mandarin Duck" = c("Females build the nest and incubate the eggs. One of many species where the female does both.",
                                          "Native to Eastern Russia and China, migrate to Japan and eastern China"),
                      "Streaked Weaver" = c("Native to South Asia and Southeast Asia",
                                            "Male is the nest builder and both incubate eggs. Low latitude and somewhat long breeding season- an outlier.",
                                            "They nest around reedbeds in wetlands"),
                      "Red legged partridge" = c("Male is the nest builder, while females incubate. They have a large clutch size.",
                                                 "Native to Southwestern Europe",
                                                 "Nest on the ground"))
      
      shiny::tags$ul(
        lapply(facts, function(fact) {
          shiny::tags$li(fact)
        })
      )
    })
  })
  
  output$nest_builder_table <- renderTable({
    tabyl(dataset, "nest_builder")
  })
  
  output$additional_inputs <- renderUI({
    plot_type <- input$master_input
    
    if (plot_type == "Distribution of Categorical Variables by Nest Builder Sex") {
      selectInput("x_var", "Select x variable:", 
                  choices = c("nest_site", "nest_structure", "incubating_sex"), 
                  selected = "nest_site")
    } else if (plot_type == "Distribution of Nest Builder by Sex Against Continuous Variables") {
      selectInput("y_var", "Select y variable:", 
                  choices = c("clutch_size_mean", "length_breeding", "latitude_mean"), 
                  selected = "clutch_size_mean")
    } else if (plot_type == "Trends in Breeding Season Length (and Other Continuous Variables)") {
      selectInput("y_var", "Select y variable:", 
                  choices = c("clutch_size_mean", "latitude_mean"), 
                  selected = "latitude_mean")
    } else if (plot_type == "Differences Between Variables Across Different Genuses") {
      selectInput("y_var", "Select y variable:", 
                  choices = c("nest_builder", "nest_site", "nest_structure", "incubating_sex", 
                              "clutch_size_mean", "length_breeding", "latitude_mean"), 
                  selected = "nest_builder")
    }
  })
  
  output$plot <- renderPlot({
    plot_type <- input$master_input
    
    if (plot_type == "Distribution of Categorical Variables by Nest Builder Sex") {
      dataset %>%
        ggplot(aes_string(x = input$x_var, fill = "nest_builder")) +
        geom_bar(position = "dodge", na.rm=TRUE) +
        theme(axis.text.x = element_text(angle = 50, hjust = 1)) +
        labs(x = input$x_var, y = "Count", fill = "Sex") +
        scale_fill_brewer(palette = "YlGnBu")
    } else if (plot_type == "Distribution of Nest Builder by Sex Against Continuous Variables") {
      dataset %>%
        ggplot(aes_string(x = "nest_builder", y = input$y_var, fill = "nest_builder")) +
        geom_boxplot(na.rm=TRUE) +
        theme(axis.text.x = element_text(angle = 50, hjust = 1)) +
        labs(x = "Sex", y = input$y_var) +
        scale_fill_brewer(palette = "YlGnBu")
    } else if (plot_type == "Trends in Breeding Season Length (and Other Continuous Variables)") {
      dataset %>%
        filter(!is.na(input$y_var)) %>% 
        ggplot(aes_string(x = "length_breeding", y = input$y_var)) +
        geom_point(na.rm=TRUE) +
        geom_smooth(method = "lm", se = FALSE) +
        theme(axis.text.x = element_text(angle = 50, hjust = 1)) +
        labs(x = "Length of Breeding Season", y = input$y_var) +
        scale_fill_brewer(palette = "YlGnBu")
    } else if (plot_type == "Differences Between Variables Across Different Genuses") {
      genus_filtered_dataset <- filter(dataset, genus %in% large_genuses)
      p <- ggplot(genus_filtered_dataset, aes_string(x = "genus", y = input$y_var)) +
        theme(axis.text.x = element_text(angle = 50, hjust = 1)) +
        labs(x = "Genus", y = input$y_var)
      if (input$y_var %in% c("nest_builder", "nest_site", "nest_structure", "incubating_sex")) {
        p <- p + geom_count(color = "#7fcdbb")
      } else if (input$y_var %in% c("clutch_size_mean", "length_breeding", "latitude_mean")) {
        p <- p + geom_boxplot(fill = "#7fcdbb")
      }
      print(p)
    }
  })
}
shinyApp(ui, server)