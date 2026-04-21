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
    dnf install python3 gcc python3-devel -y &>> $LOGFILE
    VALIDATE $? "Installing Python3, GCC and Python3-Devel packages" 

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

    curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOGFILE
    VALIDATE $? "Downloading payment.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    rm -rf /app/* &>> $LOGFILE
    VALIDATE $? "Removing the existing code"

    unzip /tmp/payment.zip &>> $LOGFILE
    VALIDATE $? "Unzipping payment.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    pip3 install -r requirements.txt &>> $LOGFILE
    VALIDATE $? "Installing Dependencies"

    cp /home/ec2-user/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
    VALIDATE $? "Copying Payment Service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "Daemon Reloading"

    systemctl enable payment &>> $LOGFILE
    VALIDATE $? "Enabling Payment"

    systemctl start payment &>> $LOGFILE
    VALIDATE $? "Starting Payment"

fi



