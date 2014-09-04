

Recommendation system is used in day to day life. It is used in book search, online shopping, movie search, social networking, to name a few. Recommendation system applies statistical and knowledge discovery techniques to provide recommendation to new item to the user based on previously recorded data. The recommendation information can be used to increase customer retention, promote cross-selling, and add value to buyer-seller relationship. 

Broadly recommender systems are classified into two categories:
  - Content based: recommending items that shares some common attributes based on user preferences
  - Collaborative filtering: recommending item from users sharing common preferences.
  
Commonly used metrics to quantify the performace of recommender systems are Root Mean Squared Error (RMSE), precision and Recall. 

R has a nice package recommenderlab that provides infrastructure to develop and test recommender algorithm. recommenderlab focusses on recommender algorithm based on collaborative filtering.

I used **recommenderlab** to get insight into collaborative filtering algorithms and evalaute the performace of different algorithm available in the framework on Movie Lens 100k dataset. The dataset is downloaded from [here](http://files.grouplens.org/datasets/movielens/ml-100k/).








```r
###### Recommender System algorithm implementaion on Movie Lens 100k data ###

## load libraries ####
library(recommenderlab)
library(reshape2)


# Load Movie Lens data
dataList<- readData()
# data cleansing and preprocessing
ratingDF<- preProcess(dataList$ratingDF, dataList$movieDF)
# create movie rating matrix
movieRatingMat<- createRatingMatrix(ratingDF)
# evaluate models
evalList <- evaluateModels(movieRatingMat)
```

```
## RANDOM run 
## 	 1  [0sec/0.52sec] 
## POPULAR run 
## 	 1  [0.03sec/0.14sec] 
## UBCF run 
## 	 1  [0.01sec/21.17sec]
```

The plot for comparing "Random", "Popular", "UBCF" based recommender algorithm is shown:


```r
# plot evaluation result
visualise(evalList)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-31.png) ![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-32.png) 

The visualisation shows "UBCF" algorithm has highest precision. So I picked "UBCF" to predicts top 10  recommendation of user with userID = 1. 


```r
## on visualization, looks like UBCF has highest precision.
# get Confusion matrix for "UBCF"
getConfusionMatrix(evalList[["UBCF"]])[[1]][,1:4]
```

```
##        TP      FP    FN   TN
## 1  0.4842  0.5053 51.93 1601
## 3  1.2842  1.6842 51.13 1600
## 5  2.0526  2.8947 50.36 1599
## 10 3.4947  6.4000 48.92 1595
## 15 4.7053 10.1368 47.71 1591
## 20 5.8737 13.9158 46.54 1588
```

```r
## run "UBCF" recommender
rec_model <- createModel(movieRatingMat, "UBCF")
userID <- 1
topN <- 5
recommendations(movieRatingMat, rec_model, userID, topN)
```

```
## [[1]]
## [1] "Glory (1989)"             "Schindler's List (1993)" 
## [3] "Close Shave, A (1995)"    "Casablanca (1942)"       
## [5] "Leaving Las Vegas (1995)"
```

The complete R code can be found [here]().
