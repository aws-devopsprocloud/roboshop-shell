#!/bin/bash 

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

DATE=$(date +%F-%H-%M-%S)

LOGFILE=/tmp/$0-$DATE.log

VALIDATE () {
    if [ $1 -ne 0 ]
    then 
        echo -e "ERROR: $2 ...is $R FAILED $N"
    else 
        echo -e "$2....is $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR: Please run this script with root access $N"
else 
    dnf module disable nodejs -y &>> $LOGFILE
    VALIDATE $? "Disabling NodeJS" 

    dnf module enable nodejs:20 -y &>> $LOGFILE
    VALIDATE $? "Enabling NodeJS:20"

    dnf install nodejs -y &>> $LOGFILE
    VALIDATE $? "Installing NodeJS:20"

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE
    VALIDATE $? "Creating Roboshop system user"

    mkdir /app &>> $LOGFILE
    VALIDATE $? "Creating /app directory"

    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGFILE
    VALIDATE $? "Downloading catalogue.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    unzip /tmp/catalogue.zip &>> $LOGFILE
    VALIDATE $? "Unzipping catalogue.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    npm install &>> $LOGFILE
    VALIDATE $? "Installing Dependencies"

    cp /home/ec2-user/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
    VALIDATE $? "Copying Catalogue Service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "Daemon Reloading"

    systemctl enable catalogue &>> $LOGFILE
    VALIDATE $? "Enabling Catalogue"

    systemctl start catalogue &>> $LOGFILE
    VALIDATE $? "Starting Catalogue"

    cp /home/ec2-user/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? "Copying Mongo Repo"

    dnf install mongodb-mongosh -y &>> $LOGFILE
    VALIDATE $? "Installing Mongodb Client"

    mongosh --host 172.31.37.170 </app/db/master-data.js
    VALIDATE $? "Inserting catalogue data into mongodb"

fi



