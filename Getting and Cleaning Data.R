#Load packages 
library(knitr)
library(plyr)
library(downloader)



if(!file.exists("finalProject")){
  dir.create("finalProject")
}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


if(!file.exists("finalProject/project_Dataset.zip")){
  download.file(Url,destfile="finalProject/project_Dataset.zip", mode = "wb")
}


if(!file.exists("finalProject/UCI HAR Dataset")){
  unzip(zipfile="finalProject/project_Dataset.zip",exdir="finalProject")
}


path <- file.path("finalProject" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

labelTrain <- read.table(file.path(path, "train", "y_train.txt"), header = FALSE)
labelTest  <- read.table(file.path(path, "test" , "y_test.txt" ), header = FALSE)

subTrain <- read.table(file.path(path, "train", "subject_train.txt"), header = FALSE)
subTest  <- read.table(file.path(path, "test" , "subject_test.txt"), header = FALSE)

setTrain <- read.table(file.path(path, "train", "X_train.txt"), header = FALSE)
setTest  <- read.table(file.path(path, "test" , "X_test.txt" ), header = FALSE)


rSub <- rbind(subTrain, subTest)
rLabel<- rbind(labelTrain, labelTest)
rSet<- rbind(setTrain, setTest)

names(rSub)<-c("subject")
names(rLabel)<- c("activity")
rSetNames <- read.table(file.path(path, "features.txt"), head=FALSE)
names(rSet)<- rSetNames$V2

dataCombine <- cbind(rSub, rLabel)
merge <- cbind(rSet, dataCombine)

subrSetNames<-rSetNames$V2[grep("mean\\(\\)|std\\(\\)", rSetNames$V2)]
selectedNames<-c(as.character(subrSetNames), "subject", "activity" )
merge<-subset(merge,select=selectedNames)

activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
merge$activity<-factor(merge$activity,labels=activityLabels[,2])

names(merge)<-gsub("^t", "time", names(merge))
names(merge)<-gsub("^f", "frequency", names(merge))
names(merge)<-gsub("Gyro", "Gyroscope", names(merge))
names(merge)<-gsub("Acc", "Accelerometer", names(merge))
names(merge)<-gsub("BodyBody", "Body", names(merge))
names(merge)<-gsub("Mag", "Magnitude", names(merge))

newData<-aggregate(. ~subject + activity, merge, mean)
newData<-newData[order(newData$subject,newData$activity),]
write.table(newData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')