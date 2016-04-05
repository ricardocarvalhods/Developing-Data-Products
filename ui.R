library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("journal"),
                  tags$head(
                    tags$style(HTML("
      @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
      
      h1 {
        font-family: 'Lobster', cursive;
        font-weight: 500;
        line-height: 1.1;
        color: #48ca3b;
      }
      h2 {
        font-family: 'Lobster', cursive;
        font-weight: 500;
        line-height: 1.1;
        color: gray;
      }
      h3 {
        font-family: 'Lobster', cursive;
        font-weight: 500;
        line-height: 1.1;
        color: blue;
      }

    "))
                  ),                
                  
  headerPanel("Death Risk by Age and Gender"),
  sidebarPanel(
    sliderInput('age', 'Age:', 45, min = 0, max = 99, step = 1),
    radioButtons("gender", "Gender:",
                 c("Male" = "Male",
                   "Female" = "Female")),
    actionButton('goButton', "Submit"),
    HTML("<br/><br/><br/>"),
    HTML('<b>Documentation:</b><br/>'),
    HTML("This shiny app was built based on data from <a target='blank' href='http://www.medicine.ox.ac.uk/bandolier/booth/Risk/dyingage.html'>this website</a>. 
         Data were taken from UK national mortality statistics, which provides death rates per million 
         population by age and sex. These have been recalculated to show the results as an annual risk 
         (a chance of 1 in X) and as a probability of dying in the next year, on average, by your age and your sex."),
    HTML("<br/><br/>"),
    HTML('<b>Instructions:</b><br/>'),
    HTML("<b>1)</b> Select your age from the slider <br/>
          <b>2)</b> Select your gender from the radio button <br/>
          <b>3)</b> Click on the Submit button <br/>
          Your death risk analysis will be showed on tabs on the right."),
    HTML("<br/><br/>"),
    HTML('<b>GitHub repository with .R files:</b>'),
    HTML("<a target='blank' href='https://github.com/ricardoscr/Developing-Data-Products/'>Link</a>"),
    HTML("<br/><br/>")
    
  ),
  mainPanel(
    uiOutput('myoutput')
  )
))
