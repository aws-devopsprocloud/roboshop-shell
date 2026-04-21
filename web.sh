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
    dnf module disable nginx -y &>> $LOGFILE
    VALIDATE $? "Disabling Nginx"

    dnf module enable nginx:1.24 -y &>> $LOGFILE
    VALIDATE $? "Enabling Nginx:1:24"

    dnf install nginx -y &>> $LOGFILE
    VALIDATE $? "Installing Nginx"

    systemctl enable nginx &>> $LOGFILE
    VALIDATE $? "Enabling Nginx"

    systemctl start nginx &>> $LOGFILE
    VALIDATE $? "Starting Nginx"

    rm -rf /usr/share/nginx/html/* &>> $LOGFILE
    VALIDATE $? "Removing Default Nginx Content"

    curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGFILE
    VALIDATE $? "Downloading frontend.zip"    

    cd /usr/share/nginx/html &>> $LOGFILE
    VALIDATE $? "Going to nginx directory"  

    unzip /tmp/frontend.zip &>> $LOGFILE
    VALIDATE $? "Unzipping frontend.zip"  

    cp /home/ec2-user/nginx.conf /etc/nginx/nginx.conf &>> $LOGFILE
    VALIDATE $? "Copying nginx.conf"  

    systemctl restart nginx &>> $LOGFILE
    VALIDATE $? "Restarting Nginx"  
fi

