#Gotta install package data.table
#install.packages("data.table")

#taking the variables names and activities names
features<-read.table("./UCI_HAR_Dataset/features.txt")
activityLabels<-read.table("./UCI_HAR_Dataset/activity_labels.txt")


#taking the test data
testData<-read.table("./UCI_HAR_Dataset/test/X_test.txt")
subjectTest<-read.table("./UCI_HAR_Dataset/test/subject_test.txt")
testLabels<-read.table("./UCI_HAR_Dataset/test/y_test.txt")


#taking the train data
trainData<-read.table("./UCI_HAR_Dataset/train/X_train.txt")
subjectTrain<-read.table("./UCI_HAR_Dataset/train/subject_train.txt")
trainLabels<-read.table("./UCI_HAR_Dataset/train/y_train.txt")


#creating tables for test and train with subjects, labels and variables
testData<-data.table(subjectTest,testLabels,testData)
trainData<-data.table(subjectTrain,trainLabels,trainData)

#lets set the names to the variables and subjects and activities
setnames(testData,c(1,2),c("Subject", "Activity"))
setnames(trainData,c(1,2),c("Subject", "Activity"))

completeData<-rbind(testData,trainData)
#completeData<-merge(testData,trainData,all=TRUE)
#set names to all the variables
setnames(completeData,3:(dim(completeData)[2]),as.character(features[,2]))

#selecting the mean and std variables 
meanVariables<-features[grep("mean()",features$V2,fixed= TRUE),]
stdVariables<-features[grep("std()",features$V2,fixed= TRUE),]
variablesToKeep<-rbind(meanVariables,stdVariables)
#index of the columns of the variables to be kept
variablesToKeep<-c(1,2,sort(variablesToKeep[,1])+2)

#Tidy data, we have to use the with because it is a data.table
TidyData<-completeData[,variablesToKeep,with=FALSE]
TidyData<-TidyData[order(TidyData$Subject,TidyData$Activity),]

result<-aggregate(TidyData[,3:dim(TidyData)[2],with=FALSE],by=list(Subject=TidyData$Subject,Activity=TidyData$Activity),mean)
#result<-aggregate(TidyData,by=list(Sub=TidyData$Subject,Act=TidyData$Activity),mean)
result<-result[order(result$Subject),]

# naming the activity column
result$Activity <- factor(result$Activity, labels=as.character(activityLabels[,2]))

#write table with results
write.table(result, 'Result.txt', row.names=FALSE)