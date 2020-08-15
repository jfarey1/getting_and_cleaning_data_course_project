#Run Analysis

#1. Merge the training and the test sets to create one data set.

##Obtain files in zip:
if(!file.exists("./data")) {dir.create("./data")}
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "./data/smartphoneData.zip"
download.file(zipUrl, destfile = zipFile, method = "curl")

##Show file names in zip file:
unzip(zipFile, list = T)

##Unzip required files, assign to tables. Assign text entries to characters:
features<-read.table(unz(zipFile, "UCI HAR Dataset/features.txt"), header=F)
features<-as.character(features[,2])
activityLabels<-read.table(unz(zipFile, "UCI HAR Dataset/activity_labels.txt"), header=F)
activityLabels<-as.character(activityLabels[,2])
dataTrainX<-read.table(unz(zipFile, "UCI HAR Dataset/train/X_train.txt"), header=F)
dataTrainY<-read.table(unz(zipFile, "UCI HAR Dataset/train/y_train.txt"), header=F)
dataTrainSubject<-read.table(unz(zipFile, "UCI HAR Dataset/train/subject_train.txt"), header=F)
dataTestX<-read.table(unz(zipFile, "UCI HAR Dataset/test/X_test.txt"), header=F)
dataTestY<-read.table(unz(zipFile, "UCI HAR Dataset/test/y_test.txt"), header=F)
dataTestSubject<-read.table(unz(zipFile, "UCI HAR Dataset/test/subject_test.txt"), header=F)

##Unlink zip file:
unlink(zipFile)

##Create data frames merging dataTrainY and dataTrainX, as well as dataTestY, dataTestX:
dataTrain<-data.frame(dataTrainSubject, dataTrainY, dataTrainX)
dataTest<-data.frame(dataTestSubject, dataTestY, dataTestX)

##Rename columns using features character vector:
names(dataTrain)<-c(c("subject", "activity"), features)
names(dataTest)<-c(c("subject", "activity"), features)

##Merge both created datasets:
data<-rbind(dataTrain, dataTest)


#2. Extracts only the measurements on the mean and standard deviation for each measurement.

##Find columns that contain mean and std 
##(as set out in features_info document: these are measures for mean and standard deviation respectively)

dataExtr<-data[,which(colnames(data) %in% c("subject", "activity", grep("mean()|std()", colnames(data), value=TRUE)))]

#3. Uses descriptive activity names to name the activities in the data set
##Assign activityLabels names to activity column:
dataExtr$activity<-activityLabels[dataExtr$activity]

#4. Appropriately label the data set with descriptive variable names

##Show variable names
names(dataExtr)
##Find unique values
unique(gsub("-(mean|std)().*", "", names(dataExtr)[-c(1:2)]))

##From these names, we can then assign suitable legible variable names using gsub
names(dataExtr)[-c(1:2)]<-gsub("^t", "time", names(dataExtr)[-c(1:2)])
names(dataExtr)[-c(1:2)]<-gsub("^f", "frequency", names(dataExtr)[-c(1:2)])
names(dataExtr)[-c(1:2)]<-gsub("Acc", "Accelerometer", names(dataExtr)[-c(1:2)])
names(dataExtr)[-c(1:2)]<-gsub("Gyro", "Gyroscope", names(dataExtr)[-c(1:2)])
names(dataExtr)[-c(1:2)]<-gsub("Mag", "Magnitude", names(dataExtr)[-c(1:2)])
names(dataExtr)[-c(1:2)]<-gsub("BodyBody", "Body", names(dataExtr)[-c(1:2)])

#5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject
##Using aggregate function over subject and activity columns, specifying mean:
tidyData<-aggregate(. ~ subject + activity, dataExtr, mean)
##Sort by subject and activity to tidy the tidyData:
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]

#For reference: 

##.txt file of tidy data set
write.table(tidyData, file = "tidyData.txt", row.name=FALSE)

##Variable names for codebook
tidyDataColNames <- colnames(tidyData)
write.table(tidyDataColNames, file = "colNames.txt")