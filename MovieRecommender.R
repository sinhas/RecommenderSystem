###### Recommender System algorithm implementaion on Movie Lens 100k data ###

## load libraries ####
library(recommenderlab)
library(reshape2)

######Function Definitions ##

#### Read Data ####
## data downloaded from http://grouplens.org/datasets/movielens/ 

## read the rating data for all users 
readData <- function(){
  
  ratingDF <- read.delim("./data/u.data", header=F)
  colnames(ratingDF) <- c("userID","movieID","rating", "timestamp")
  
  ## read movie data
  moviesDF <- read.delim("./data/u.item", sep="|", header=F, stringsAsFactors = FALSE)
  colnames(moviesDF)[colnames(moviesDF)=="V1"] <- "movieID"
  colnames(moviesDF)[colnames(moviesDF)=="V2"] <- "name"
  
  return(list(ratingDF=ratingDF, movieDF=moviesDF))
  
}

#### data Cleansing and processing ####
preProcess = function(ratingDF, moviesDF)
{ 
  ratingDF[,2] <- dataList$movieDF$name[as.numeric(ratingDF[,2])]
  
  # remove duplicate entries for any user-movie combination
  ratingDF <- ratingDF[!duplicated(ratingDF[,1:2]),]
}

## Create movie ratingMatrix from rating Data and movie data ####
createRatingMatrix <- function(ratingDF)
{
  # converting the ratingData data frame into rating marix
  ratingDF_tmp <- dcast( ratingDF, userID ~ movieID, value.var = "rating" , index="userID")
  ratingDF <- ratingDF_tmp[,2:ncol(ratingDF_tmp)]
  
  ratingMat <- as(ratingDF, "matrix")  ## cast data frame as matrix
  movieRatingMat <- as(ratingMat, "realRatingMatrix")   ## create the realRatingMatrix
  ### setting up the dimnames ###
  dimnames(movieRatingMat)[[1]] <- row.names(ratingDF)
  return (movieRatingMat)
}


##### Create Recommender Model ####
evaluateModels <- function(movieRatingMat)
{
  
  ## Find out and anlayse available  recommendation algorithm option for realRatingMatrix data
  recommenderRegistry$get_entries(dataType = "realRatingMatrix")
  
  scheme <- evaluationScheme(movieRatingMat, method = "split", train = .9,
                             k = 1, given = 10, goodRating = 4)
  
  algorithms <- list(
    RANDOM = list(name="RANDOM", param=NULL),
    POPULAR = list(name="POPULAR", param=NULL),
    UBCF = list(name="UBCF", param=NULL)
  )
  
  # run algorithms, predict next n movies
  results <- evaluate(scheme, algorithms, n=c(1, 3, 5, 10, 15, 20))
  
  ## select the first results
  
  return (results)
}


visualise <- function(results)
{
  # Draw ROC curve
  plot(results, annotate = 1:3, legend="topright")
  
  # See precision / recall
  plot(results, "prec/rec", annotate=3, legend="topright", xlim=c(0,.22))
}


#### Create prediction model ####
createModel <-function (movieRatingMat,method){
  
  model <- Recommender(movieRatingMat, method = method)
  names(getModel(model))
  getModel(model)$method
  
  getModel(model)$nn
  
  return (model)
}


### Predict user rating using UBCF recommendation algoithm ####
recommendations <- function(movieRatingMat, model, userID, n)
{
  
  ### predict top n recommendations for given user
  topN_recommendList <-predict(model,movieRatingMat[userID],n=n)
  as(topN_recommendList,"list")
}


# Load Movie Lens data
dataList<- readData()
# data cleansing and preprocessing
ratingDF<- preProcess(dataList$ratingDF, dataList$movieDF)
# create movie rating matrix
movieRatingMat<- createRatingMatrix(ratingDF)
# evaluate models
evalList <- evaluateModels(movieRatingMat)


# plot evaluation result
visualise(evalList)

## on visualization, looks like UBCF has highest precision.
# get Confusion matrix for "UBCF"
getConfusionMatrix(evalList[["UBCF"]])[[1]][,1:4]

## run "UBCF" recommender
rec_model <- createModel(movieRatingMat, "UBCF")
userID <- 1
topN <- 5
recommendations(movieRatingMat, rec_model, userID, topN)




