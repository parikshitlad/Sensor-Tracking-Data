install.packages("reshape2")
install.packages("data.table")
library(reshape2)
library(data.table)

# download, unzip and read file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "data_file.zip", method="curl")
unzip("data_file.zip")

#read all the test data, and combine along with subject, activity id and activity name
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
data_test_x <- read.table("./UCI HAR Dataset/test/X_test.txt")
data_test_y <- read.table("./UCI HAR Dataset/test/y_test.txt")
activity_names <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
col_activity <- factor(data_test_y[,1], labels = activity_names)
combined_test <- cbind(subject_test,data_test_y, col_activity, data_test_x)

#read all the training data, and combine along with subject, activity id and activity name
#using the same col_acitivity variable so that rbind doesn't give an error of different col names
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
data_train_x <- read.table("./UCI HAR Dataset/train/X_train.txt")
data_train_y <- read.table("./UCI HAR Dataset/train/y_train.txt")
col_activity <- factor(data_train_y[,1], labels = activity_names)
combined_train <- cbind(subject_train, data_train_y, col_activity, data_train_x)

#combine test and train data
c_test_train <- rbind(combined_test,combined_train)

#read all column names and combine with new col names of sunbject, activity id, and activity
col_labels <- read.table("./UCI HAR Dataset/features.txt")[,2]
col_labels_2 <- c("Subject","Activity_ID", "Activity")
labels <- c(col_labels_2,col_labels_1)

#assign column names to the combined dataset
colnames(c_test_train) <- labels

#subset for mean and std variables
mean_labels <- grepl("mean", labels, ignore.case=TRUE)
SD_labels <- grepl("std", labels, ignore.case=TRUE)
mean_SD <- (mean_labels | SD_labels)
mean_SD[1:3] <- TRUE

c_mean_SD <- c_test_train[,mean_SD]

#melt and cast with tidy data to compute averages. Then write to file
melt_data <- melt(c_mean_SD, id=c("Subject","Activity_ID", "Activity"))
tidy_data <- dcast(melt_data, Subject + Activity_ID + Activity ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt", row.name=FALSE)
