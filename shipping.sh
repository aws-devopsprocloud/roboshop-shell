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
    dnf install maven -y &>> $LOGFILE
    VALIDATE $? "Installing Maven" 

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

    curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOGFILE
    VALIDATE $? "Downloading shippinhg.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    rm -rf /app/* &>> $LOGFILE
    VALIDATE $? "Removing the existing code"

    unzip /tmp/shipping.zip &>> $LOGFILE
    VALIDATE $? "Unzipping shipping.zip"

    cd /app &>> $LOGFILE
    VALIDATE $? "Going to /app directory"

    mvn clean package &>> $LOGFILE
    VALIDATE $? "Installing Dependencies"

    mv target/shipping-1.0.jar shipping.jar 
    VALIDATE $? "Renaming shipping-1.0 file to shipping.jar"

    cp /home/ec2-user/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
    VALIDATE $? "Copying Shipping Service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "Daemon Reloading"

    systemctl enable shipping &>> $LOGFILE
    VALIDATE $? "Enabling Shipping"

    systemctl start shipping &>> $LOGFILE
    VALIDATE $? "Starting Shipping"

    systemctl install mysql -y &>> $LOGFILE
    VALIDATE $? "Installing MySQL Client" 

    mysql -h mysql.devopsprocloud.in -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE
    VALIDATE $? "Inserting schema into MySQL" 

    mysql -h mysql.devopsprocloud.in -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE
    VALIDATE $? "Inserting app-user schema into MySQL" 

    mysql -h mysql.devopsprocloud.in -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE
    VALIDATE $? "Inserting master-data shcema into MySQL" 

    systemctl restart shipping &>> $LOGFILE
    VALIDATE $? "Restarting Shipping"
fi