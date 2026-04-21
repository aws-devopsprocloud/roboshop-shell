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
      
    cp /home/ec2-user/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? "Copying Mongodb Repo"

    dnf install mongodb-org -y &>> $LOGFILE
    VALIDATE $? "Installing Mongodb"

    systemctl enable mongod &>> $LOGFILE
    VALIDATE $? "Enabling Mongodb"

    systemctl start mongod &>> $LOGFILE
    VALIDATE $? "Starting Mongodb"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
    VALIDATE $? "Allowing remote connections"

    systemctl restart mongod &>> $LOGFILE
    VALIDATE $? "Restarting Mongodb"
fi