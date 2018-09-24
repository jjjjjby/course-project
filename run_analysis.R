# 1. Merge the training and the test sets to create one data set.

## download zip file from website
if(!file.exists("./data")) dir.create("./data")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/projectData_getCleanData.zip")

## unzip data
listZip <- unzip("./data/projectData_getCleanData.zip", exdir = "./data")

## load data into R
train.x <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train.y <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
train.subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
test.x <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test.y <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
test.subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## merge the data
trainData<-cbind(train.subject,train.y,train.x)
testData<-cbind(test.subject,test.y,test.x)
wholeData<-rbind(trainData,testData)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
featureName <- read.table("./data/UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)[,2]
featureIndex <- grep(("mean\\(\\)|std\\(\\)"), featureName)
Data<-wholeData[, c(1,2, featureIndex+2)]
colnames(Data) <- c("subject","activity", featureName[featureIndex])

# 3. Uses descriptive activity names to name the activities in the data set
activityName <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
Data$activity <- factor(Data$activity, levels = activityName[,1], labels = activityName[,2])

# 4. Appropriately labels the data set with descriptive variable names.

names(Data) <- gsub("\\()", "", names(Data))
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequence", names(Data))
names(Data) <- gsub("-mean", "Mean", names(Data))
names(Data) <- gsub("-std", "Std", names(Data))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(dplyr)
groupData <- Data %>%
        group_by(subject, activity) %>%
        summarise_each(funs(mean)) %>%
        print

write.csv(groupData, "./MeanData.csv", row.names = FALSE)
