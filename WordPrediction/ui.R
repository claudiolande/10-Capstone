
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    # Application title
    titlePanel("Word prediction app"),

    mainPanel(
        tabsetPanel(type = "tabs", 
            tabPanel("Word prediction", 
                h4("Type a short sentence and press the 'Predict word' button"),
                h5("Warning! Predicting the next word can take up to 45 seconds! Please be patient!"),
                textInput("searchString", label = NULL),
                submitButton(text = "Predict word"),
                h4(textOutput("predictedWord")),
                tags$head(tags$style("#predictedWord{color: red;
                            font-size: 20px;
                            font-style: italic;
                        }"
                    )
                )
            ),
            tabPanel("Instructions", br(), 
                 h1("Instructions"), 
                 p("This app predicts the next word in a given sentence. The algorithm uses the last words of the sentence as the context to predict the new word."),
                 p("Usage is straightforward:"),
                 p("- type a few words in the text area and then press 'Predict word' button"),
                 p("- the application will suggest the next word of your sentence"),
                 p("For example you could type: 'as a matter of ', 'in spite of', 'My name is'"),
                 p("For more information about the application, please see:"),
                 a("http://rpubs.com/claudiolande/InteractiveBarcelonaTouristMap", 
                   href = "http://rpubs.com/claudiolande/InteractiveBarcelonaTouristMap")
            )
        )
    )
))
