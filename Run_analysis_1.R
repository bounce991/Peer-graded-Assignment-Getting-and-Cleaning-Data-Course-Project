
if(!library(reshape2, logical.return = TRUE)) {

  install.packages('reshape2')
  library(reshape2)
}


targetFolder <- 'UCI HAR Dataset'
filename <- 'getdata_dataset.zip'


if(!file.exists(targetFolder)) {
  
  if(!file.exists(filename)) {
    
    
    download.file(
      'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
      filename
    )
  }
  
 
  unzip(filename)
}




test.data <- read.table(file.path(targetFolder, 'test', 'X_test.txt'))
test.activities <- read.table(file.path(targetFolder, 'test', 'y_test.txt'))
test.subjects <- read.table(file.path(targetFolder, 'test', 'subject_test.txt'))

train.data <- read.table(file.path(targetFolder, 'train', 'X_train.txt'))
train.activities <- read.table(file.path(targetFolder, 'train', 'y_train.txt'))
train.subjects <- read.table(file.path(targetFolder, 'train', 'subject_train.txt'))


data.data <- rbind(train.data, test.data)
data.activities <- rbind(train.activities, test.activities)
data.subjects <- rbind(train.subjects, test.subjects)


full_data <- cbind(data.subjects, data.activities, data.data)




features <- read.table(file.path(targetFolder, 'features.txt'))


requiredFeatures <- features[grep('-(mean|std)\\(\\)', features[, 2 ]), 2]
full_data <- full_data[, c(1, 2, requiredFeatures)]



activities <- read.table(file.path(targetFolder, 'activity_labels.txt'))

full_data[, 2] <- activities[full_data[,2], 2]


colnames(full_data) <- c(
  'subject',
  'activity',
 
  gsub('\\-|\\(|\\)', '', as.character(requiredFeatures))
)


full_data[, 2] <- as.character(full_data[, 2])
final.melted <- melt(full_data, id = c('subject', 'activity'))

final.mean <- dcast(final.melted, subject + activity ~ variable, mean)

write.table(final.mean, file=file.path("tidy.txt"), row.names = FALSE, quote = FALSE)

