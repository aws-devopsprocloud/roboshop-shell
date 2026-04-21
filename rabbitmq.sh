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
    cp /home/ec2-user/roboshop-shell/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGFILE
    VALIDATE $? "Copying rabbitmq repo"

    dnf install rabbitmq-server -y &>> $LOGFILE
    VALIDATE $? "Installing Rabbitmq Server"

    systemctl enable rabbitmq-server &>> $LOGFILE
    VALIDATE $? "Enabling rabbitmq"

    systemctl start rabbitmq-server &>> $LOGFILE
    VALIDATE $? "Starting rabbitmq"

    rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
    VALIDATE $? "Adding the roboshop credentials"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
    VALIDATE $? "Setting up the permissions to teh Roboshop User"

fi