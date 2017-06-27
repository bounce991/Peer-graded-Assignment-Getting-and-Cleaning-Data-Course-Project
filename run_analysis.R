#------------------------------------------------------#
#Created by: John Hamm
#Coursera Getting and Cleaning Data: Final Assignment
#Date: 06/26/2017 - 06/27/2017
#------------------------------------------------------#

#Load the necessary packages for the assignment
library(plyr)
library(downloader)
library(knitr)

#Start by unzipping the file if it is not in the directory and has not been downloaded or unzipped
#Using a linux sandbox of R, so getting the file this way is easier 

#Create a directory if there isnt already one
if(!file.exists("finalProject")){
  dir.create("finalProject")
}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#If the zip file doesn't exist downlad it from the above url
if(!file.exists("finalProject/project_Dataset.zip")){
  download.file(Url,destfile="finalProject/project_Dataset.zip", mode = "wb")
}

#Unzip the file if it hasn't already been unzipped
if(!file.exists("finalProject/UCI HAR Dataset")){
  unzip(zipfile="finalProject/project_Dataset.zip",exdir="finalProject")
}

#List all the files
path <- file.path("finalProject" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

#Read the text files

#Labels
labelTrain <- read.table(file.path(path, "train", "y_train.txt"), header = FALSE)
labelTest  <- read.table(file.path(path, "test" , "y_test.txt" ), header = FALSE)

#Subjects
subTrain <- read.table(file.path(path, "train", "subject_train.txt"), header = FALSE)
subTest  <- read.table(file.path(path, "test" , "subject_test.txt"), header = FALSE)

#Sets
setTrain <- read.table(file.path(path, "train", "X_train.txt"), header = FALSE)
setTest  <- read.table(file.path(path, "test" , "X_test.txt" ), header = FALSE)

#Merging

#Making rows
rSub <- rbind(subTrain, subTest)
rLabel<- rbind(labelTrain, labelTest)
rSet<- rbind(setTrain, setTest)

#Variable Names
names(rSub)<-c("subject")
names(rLabel)<- c("activity")
rSetNames <- read.table(file.path(path, "features.txt"), head=FALSE)
names(rSet)<- rSetNames$V2

#Merge Columns
dataCombine <- cbind(rSub, rLabel)
merge <- cbind(rSet, dataCombine)

#Mean and StandardDev
subrSetNames<-rSetNames$V2[grep("mean\\(\\)|std\\(\\)", rSetNames$V2)]
selectedNames<-c(as.character(subrSetNames), "subject", "activity" )
merge<-subset(merge,select=selectedNames)

#Read in the Activity Labels document
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
merge$activity<-factor(merge$activity,labels=activityLabels[,2])

#Labeling the Merged Dataset
names(merge)<-gsub("^t", "time", names(merge))
names(merge)<-gsub("^f", "frequency", names(merge))
names(merge)<-gsub("Gyro", "Gyroscope", names(merge))
names(merge)<-gsub("Acc", "Accelerometer", names(merge))
names(merge)<-gsub("BodyBody", "Body", names(merge))
names(merge)<-gsub("Mag", "Magnitude", names(merge))

#Making the Tidy Dataset (newData) and writing it to a text file
newData<-aggregate(. ~subject + activity, merge, mean)
newData<-newData[order(newData$subject,newData$activity),]
write.table(newData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')
