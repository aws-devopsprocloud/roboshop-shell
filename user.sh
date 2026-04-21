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
        exit 1
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

    id roboshop &>> $LOGFILE
    if [ $? -ne 0 ]
    then 
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE
        VALIDATE $? "Creating Roboshop system user"
    else 
        echo -e "Roboshop user already Exist $Y SKIPPING $N"
    fi
    
    mkdir -p /app &>> $LOGFILE
    VALIDATE $? "Creating /app directory"

    curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOGFILE
    VALIDATE $? "Downloading user.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    rm -rf /app/* &>> $LOGFILE
    VALIDATE $? "Removing the existing code"

    unzip /tmp/user.zip &>> $LOGFILE
    VALIDATE $? "Unzipping user.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    npm install &>> $LOGFILE
    VALIDATE $? "Installing Dependencies"

    cp /home/ec2-user/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
    VALIDATE $? "Copying User Service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "Daemon Reloading"

    systemctl enable user &>> $LOGFILE
    VALIDATE $? "Enabling User"

    systemctl start user &>> $LOGFILE
    VALIDATE $? "Starting User"
fi