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
    dnf module disable redis -y &>> $LOGFILE
    VALIDATE $? "Disabling Redis" 

    dnf module enable redis:7 -y &>> $LOGFILE
    VALIDATE $? "Disabling Redis:7" 

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
    VALIDATE $? "Allowing Remote Connections" 

    systemctl enable redis &>> $LOGFILE
    VALIDATE $? "Enabling Redis" 
    
    systemctl start redis &>> $LOGFILE
    VALIDATE $? "Starting Redis" 

fi