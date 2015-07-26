library("data.table")
library("reshape2")

dir = "./UCI HAR Dataset"

# Load data
labels <- read.table(paste(dir, "/activity_labels.txt", sep=""))[,2]
features <- read.table(paste(dir, "/features.txt", sep=""))[,2]
X_test <- read.table(paste(dir, "/./test/X_test.txt", sep=""))
y_test <- read.table(paste(dir, "/./test/y_test.txt", sep=""))
X_train <- read.table(paste(dir, "/./train/X_train.txt", sep=""))
y_train <- read.table(paste(dir, "/./train/y_train.txt", sep=""))
subject_test <- read.table(paste(dir, "/./test/subject_test.txt", sep=""))
subject_train <- read.table(paste(dir, "/./train/subject_train.txt", sep=""))

# Set data column names
names(X_test) = features
names(X_train) = features

# Filter only required features
required_features <- grepl("mean|std", features)
X_test = X_test[,required_features]
X_train = X_train[,required_features]

# Set activity and subject column names
y_test[,2] = labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
y_train[,2] = labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)
data = rbind(test_data, train_data)

# Separate id columns from data columns to perform melt
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)

# Arrange data to facilitate grouping by activity and subject
melt_data   = melt(data, id = id_labels, measure.vars = data_labels)

# Group each variable by subject and activity summarizing each variable by it's mean
result   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Write the file
write.table(result, file = "./result.txt", row.names = FALSE)
