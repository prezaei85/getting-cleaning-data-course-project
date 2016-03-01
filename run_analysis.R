
# download and unzip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "fit_data.zip", method = "curl")
unzip(zipfile="fit_data.zip")

# read the activity files and combine test and train sets
activity_train = read.table("UCI HAR Dataset/train/y_train.txt")
activity_test = read.table("UCI HAR Dataset/test/y_test.txt")
activity = rbind(activity_train, activity_test)
names(activity) = "activity"

# read the subject files and combine test and train sets
subject_train = read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test = read.table("UCI HAR Dataset/test/subject_test.txt")
subject = rbind(subject_train, subject_test)
names(subject) = "subject"

# read the features and combine test and train sets
features_train = read.table("UCI HAR Dataset/train/X_train.txt")
features_test = read.table("UCI HAR Dataset/test/X_test.txt")
features = rbind(features_train, features_test)
# read the features' names
features_names = read.table("UCI HAR Dataset/features.txt")
names(features) = features_names$V2

# combine features, subject and activity
data = cbind(activity, subject, features)

# use dplyr package to handle the data more efficiently
library(dplyr)
data = tbl_df(data)
data = data[,!duplicated(names(data))] # delete the duplicated names
# select columns with "mean" or "std" in their names
data_select = select(data, activity, subject, matches("mean\\(\\)"), matches("std\\(\\)"))

# add descriptive activity names
activity_labels = read.table("UCI HAR Dataset/activity_labels.txt")
all_activity_labels = activity_labels$V2[data_select$activity]
data_select = mutate(data_select, activity = all_activity_labels)

# change names of the features into more descriptive names
names(data_select)<-gsub("^t", "time", names(data_select))
names(data_select)<-gsub("^f", "frequency", names(data_select))
names(data_select)<-gsub("Acc", "Accelerometer", names(data_select))
names(data_select)<-gsub("Gyro", "Gyroscope", names(data_select))
names(data_select)<-gsub("Mag", "Magnitude", names(data_select))
names(data_select)<-gsub("BodyBody", "Body", names(data_select))

# create an independent dataset that includes averages based on subject and activity
new_data = aggregate(. ~ subject+activity, data_select, mean)
write.table(new_data, "new_data.txt", row.names = FALSE)

