library(ggplot2)
deathdata <- data.frame(age=c('00-01','01-04','05-14','15-24','25-34','35-44','45-54','55-64','65-74','75-84','85-99','00-01','01-04','05-14','15-24','25-34','35-44','45-54','55-64','65-74','75-84','85-99'),
                        Age=c(0,2.5,10,20,30,46,50,60,70,80,90,0,2.5,10,20,30,46,50,60,70,80,90),
                        rate=c(177,4386,8333,1908,1215,663,279,112,42,15,6,227,5376,10417,4132,2488,1106,421,178,65,21,7),
                        gender=c('Male','Male','Male','Male','Male','Male','Male','Male','Male','Male','Male','Female','Female','Female','Female','Female','Female','Female','Female','Female','Female','Female'))
deathdata$age <- as.character(deathdata$age)

initial.msg <- function(input.data){
  msg <- paste0("Historical data shows that, for your age (", input.data$age, 
         ") and gender (", input.data$gender, "), the annual death risk is 1 in every ", input.data$rate, 
         ", which gives a probability of ", round(100/input.data$rate, 3), "% of dying within a year.")
  return(msg)
}

initial.plot <- function(deathdata, input.data){
  g <- ggplot(deathdata[deathdata$gender == input.data$gender,], aes(x=age, y=log(1/rate))) + geom_point(size=4) +
    geom_point(data=input.data, colour="blue", size=4) +
    geom_text(data=input.data, label="You", hjust=1.3, size=7, colour="blue") +
    labs(title=paste0("Log of the inverse of the number of ", input.data$gender, " deaths by Age"))
  return(g)
}

middle.msg <- function(input.data){
  if(input.data$age == '00-01' | input.data$age == '01-04'){  
    mid.msg <- "Since you are still under 5 years old, you lower your risk until entering the 05-14 zone, when the older you are, the greater is your risk of dying in any one year, so be careful."
  }
  else{
    mid.msg <- "Since you are already more than 5 years old, it means the older you get, the greater is your risk of dying in any one year, so be careful."
  }
  return(mid.msg)
}

final.plot <- function(deathdata, input.data){
  g <- ggplot(deathdata, aes(x=age, y=log(1/rate), color=gender)) + geom_point(size=4) +
    geom_point(data=input.data, colour="blue", size=4) +
    geom_text(data=input.data, label="You", hjust=1.3, size=7, colour="blue") +
    labs(title=paste0("Log of the inverse of the number of deaths by Age and gender"))
  return(g)
}

final.msg <- function(gender.input){
  if(gender.input == 'Male'){  
    msg <- "Additionally, as the following image shows, the risk of dying is higher if you are a man, so you need to be even more careful."
  }
  if(gender.input == 'Female'){
    msg <- "Although, as the following image shows, that risk is lower if you are a woman, so that's good news for you."
  }
  return(msg)
}

final.test <- function(input.data){
  test <- t.test(rate ~ gender, data=deathdata, paired=FALSE, var.equal=TRUE)
  if(input.data$gender == 'Male'){  
    msg <- paste0("Although, that gender analysis is too simplistic, and a Two Sample T-Test gives a p-value of ",
                  round(test$p.value, 3), ". Therefore we cannot affirm, with the data available, ",
                  "that there is a significant difference in risk for gender, which is good news for you.")
  }
  if(input.data$gender == 'Female'){
    msg <- paste0("Although, that gender analysis is too simplistic, and a Two Sample T-Test gives a p-value of ",
                  round(test$p.value, 3), ". Therefore we cannot affirm, with the data available, ",
                  "that there is a significant difference in risk for gender, so you still need to be careful.")
  }
  return(msg)
}

get.age.column <- function(age.par){
  age.input <- ""
  if(age.par <= 1){
    age.input <- "00-01"
  }
  else if(age.par <= 4){
    age.input <- "01-04"
  }
  else if(age.par <= 14){
    age.input <- "05-14"
  }
  else if(age.par <= 24){
    age.input <- "15-24"
  }
  else if(age.par <= 34){
    age.input <- "25-34"
  }
  else if(age.par <= 44){
    age.input <- "35-44"
  }
  else if(age.par <= 54){
    age.input <- "45-54"
  }
  else if(age.par <= 64){
    age.input <- "55-64"
  }
  else if(age.par <= 74){
    age.input <- "65-74"
  }
  else if(age.par <= 84){
    age.input <- "75-84"
  }
  else{
    age.input <- "85-99"
  }
  return(age.input)
}

get.pred.out <- function(deathdata, input.data){
  pred <- deathdata[deathdata$gender==input.data$gender,]
  pred$rateorig <- pred$rate
  pred$rateinv <- log(1/pred$rateorig)
  pred$age_prox2 <- pred$Age
  
  pred.out <- pred[pred$gender==input.data$gender & pred$age == input.data$age,]
  
  pred.out$rate <- as.data.frame(1/exp(predict(lm(rateinv ~ age_prox2, data=pred), pred.out)))
  
  return(pred.out)
}

rate.model <- function(deathdata, input.data){
  pred.out <- get.pred.out(deathdata, input.data)
  
  g <- ggplot(deathdata[deathdata$gender==input.data$gender,], aes(x=Age, y=log(1/rate), color=gender)) + 
    geom_point(size=4) +
    geom_smooth(method="lm", col="green", size=1) +
    geom_point(data=pred.out, colour="blue", size=4) +
    geom_text(data=pred.out, label="You", vjust=-1.2, size=7, colour="blue") +
    labs(title=paste0("Log of the inverse of the number of ", input.data$gender, " deaths by Age"))
  
  return(g)
}

msg.model <- function(gender.input){
  msg <- paste0("Using a linear regression for ", gender.input, " death risk, we can see the predictive model in the green line, along with your personal data in blue and the original dataset in red.")
  return(msg)
}

final.msg.model <- function(deathdata, input.data){
  pred.out <- get.pred.out(deathdata, input.data)
  
  if(pred.out$rate > pred.out$rateorig){
    msg0 <- "the predicted risk is smaller than the original data point, so it gives a better scenario for you, "
  }
  else if(pred.out$rate < pred.out$rateorig){
    msg0 <- "the predicted risk is bigger than the original data point, so it gives a worse scenario for you, "
  }
  else {
    msg0 <- "the predicted risk is equal to the original data point, so it gives the same scenario for you, "
  }
  msg1 <- paste0("giving a probability of ", round(100/pred.out$rate, 3), "% of dying within a year.")
  
  msg <- paste0("The linear model is supposed to be as close as possible to the actual points. In your case, ", msg0, msg1)
  
  return(msg)
}


library(shiny)
shinyServer(
  function(input, output) {
    # Get age field
    age.vl <- eventReactive(input$goButton, {get.age.column(input$age)})
    
    # Get input data from the deathdata dataset
    input.data <- eventReactive(input$goButton, {subset(deathdata, age == age.vl() & gender == input$gender)})
    
    ## Initial Message
    #output$init.msg <- renderText({initial.msg(input.data())})
    
    ## Initial Plot
    output$init.plot <- renderPlot({initial.plot(deathdata, input.data())})
    
    ## Middle Message
    #output$middle <- renderText({middle.msg(input.data())})
    
    ## Final Plot
    output$fin.plot <- renderPlot({final.plot(deathdata, input.data())})
    
    ## Final Message
    #output$fin.msg <- renderText({final.msg(input.data()$gender)})
    
    ## T.test
    #output$fin.test <- renderText({final.test(input.data())})
    
    ## Model Message
    #output$model.msg <- renderText({msg.model(input.data()$gender)})
    
    ## Model
    output$rate.model <- renderPlot({rate.model(deathdata, input.data())})
    
    # To conditionally load main panel at ui.R
    output$myoutput <- renderUI({
      if(input.data()$gender == 'Male' | input.data()$gender == 'Female'){
        tagList(
          h2('Results on 3 tabs'),
          tabsetPanel(
            tabPanel("Age Analysis", 
                     h3('Age Analysis For Your Gender'),
                     initial.msg(input.data()),
                     HTML("<br/>"),
                     plotOutput("init.plot"),
                     HTML("<br/>"),
                     
                     h4('Clinical Trend For Age'),
                     middle.msg(input.data()),
                     HTML("<br/>")
                     ), 
            tabPanel("Gender Analysis", 
                     h3('Gender Analysis For All Ages'),
                     final.msg(input.data()$gender),
                     HTML("<br/>"),
                     plotOutput("fin.plot"),
                     HTML("<br/>"),
                     h4('Clinical Trend For Gender'),
                     final.test(input.data()),
                     HTML("<br/>")
                     ), 
            tabPanel("Linear Model", 
                     h3('Predicting from Linear Model'),
                     msg.model(input.data()$gender),
                     HTML("<br/>"),
                     plotOutput("rate.model"),
                     HTML("<br/>"),
                     h4('Clinical Trend From Linear Model'),
                     final.msg.model(deathdata, input.data()),
                     HTML("<br/>")
                     )
          )
        )
      }
    })
    
  }
)