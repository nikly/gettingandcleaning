#course project code to import separate data sets, clean the data, and export a tidy data set

#import
testdata <-read.table(file.path("test","x_test.txt"))
traindata <-read.table(file.path("train","x_train.txt"))
testY <-read.table(file.path("test","y_test.txt"))
trainY <-read.table(file.path("train","y_train.txt"))
subtest <-read.table(file.path("test","subject_test.txt"), comment.char="", colClasses="numeric")
subtrain <-read.table(file.path("train","subject_train.txt"), comment.char = "", colClasses="numeric")
features <-read.table("features.txt")
activities <-read.table("activity_labels.txt")
combineddata <- rbind(traindata, testdata) #bind test & train sets
#fix column names with cleaned up features
colnames(combineddata) <- tolower(gsub("(\\W)","\\L",features$V2,perl=TRUE)) # add in feature column names
means <- combineddata[,grep("mean", colnames(combineddata))]#pull out means
means2 <- means[,-grep("freq",colnames(means))] #remove meanFreq()
std <- combineddata[,grep("std", colnames(combineddata))] #pull out std
combineddata <- cbind(means2,std) #created combineddata with variables we want
allsubjects <- rbind(subtest, subtrain) #bind subject info
colnames(allsubjects) <- "subject"
combinedY <- rbind(trainY, testY) #bind training labels
library(sqldf) #load sqldf package
#join labels
updatedactivities <- sqldf("select * from combinedY join activities using(V1)")
colnames(updatedactivities) <- c("act_code","activity")
alldata <- cbind(combineddata,allsubjects,updatedactivities) #create master data set
alldata <- subset(alldata, select=-act_code) #remove extra column act_code
library(reshape2) #load reshape2 library
melted <- melt(alldata, id=c("subject","activity")) #melt data set
averages <- dcast(melted, subject +activity ~variable,mean) #cast averages
write.csv(averages,file="tidyData.txt") #generate tidy dataset



