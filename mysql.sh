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
    dnf install mysql-server -y &>> $LOGFILE
    VALIDATE $? "Disabling MySQL Server" 

    

    systemctl enable mysqld &>> $LOGFILE
    VALIDATE $? "Enabling mysqld" 

    systemctl start mysqld &>> $LOGFILE
    VALIDATE $? "Starting MySQL" 

    mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
    VALIDATE $? "Adding Root Password" 
fi