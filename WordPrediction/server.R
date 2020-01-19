#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readtext)
library(quanteda)
library(stringi)
library(ggplot2)
library(dplyr)
library(data.table)

###################################################################################
# Helper functions
###################################################################################

# Loads a word prediction model
loadModel <- function(filename) {
    invector <- fread(filename)
    invector <- unlist(invector)
    invector
}

# returns the number of words contained in the text
countWords <- function(text) {
    toks <- tokens(text)
    toks <- toks[[1]]
    numTokens <- length(toks)
    numTokens
}

# Creates a text string concatenating the words passed as a parameter
create_ngram <- function(words) {
    new_ngram <- NULL
    numWords <- 0
    
    if(is.null(words)) {
        return(NULL)
    }
    
    numWords <- countWords(words)
    
    if(numWords == 0) {
        return(NULL)
    }
    
    words <- tokens(words)
    words <- words[[1]]
    
    for (i in 1:numWords) {
        if(!is.null(words[i])) {
            new_ngram <- paste(new_ngram, words[i], "_", sep = "")
        }
    }
    new_ngram
}

# gets the last word of an ngram
getNgramLastWord <- function(ngram) {
    words <- strsplit(ngram, "_")
    words <- words[[1]]
    len <- length(words)
    words[len]
}

# takes text and returns the last words
getLastWords <- function(text, numWords) {
    numTokens <- countWords(text)
    toks <- tokens(text)
    toks <- toks[[1]]
    lastwords <- NULL
    
    if(numWords > numTokens)
        numWords <- numTokens
    
    for (i in numWords:1) {
        currentWord <- toks[numTokens - i + 1]
        if(!is.null(currentWord)) {
            if(is.null(lastwords)) {
                lastwords <- currentWord
            }
            else {
                lastwords <- paste(lastwords, " ", currentWord, sep = "")
            }
        }
    }
    lastwords
}

# Searches a ngram in a data frame
lookupNgram <- function(dataframe, searched_ngram, max_ngram) {
    num_ngram <- 0
    len <- length(dataframe)
    result <- c()
    
    for (i in 1:len) {
        if(startsWith(dataframe[i], searched_ngram)) {
            num_ngram <- num_ngram + 1
            result <- append(result, dataframe[i])
        }
        if (num_ngram == max_ngram) {
            break
        }
    }
    result
}

# Searches a ngram in a data frame
lookupText <- function(dataframe, searched_text) {
    result_ngram <- NULL
    numTokens <- countWords(searched_text)
    
    for (i in numTokens:1) {
        searched_text <- getLastWords(searched_text, i)
        searched_ngram <- create_ngram(searched_text)
        result_ngram <- lookupNgram(dataframe, searched_ngram, 1)
        if(!is.null(result_ngram)) {
            break
        }
    }
    if (is.null(result_ngram)) {
        return(NULL)
    }
    else {
        suggestedWord <- getNgramLastWord(result_ngram)
        return(suggestedWord)
    }
}

###################################################################################
# Main
###################################################################################

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    ngram_vector <- loadModel("./wordPrediction.txt")
    
    output$predictedWord <- renderText({
        message <- NULL
        
        if(trimws(input$searchString) == "") return("")
        
        prediction <- lookupText(ngram_vector, input$searchString)
        if(is.null(prediction)) {
            message <- "Could not predict the next word"
        }
        else {
            message <- paste("Predicted word:", prediction)
        }
        message
    })
})
