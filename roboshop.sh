#!/bin/bash

export AWS_PAGER=""

# The below is for Windows 
# R="\e[91m"
# G="\e[32m"
# Y="\e[33m"
# B="\e[94m"
# N="\e[0m"

# the below is for mac os terminal
R="\033[91m"
G="\033[32m"
Y="\033[33m"
B="\033[94m"
N="\033[0m"

AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-073d40ac23ccdcec7
ZONE_ID=Z059178135GSKTAXVUIAQ
DOMAIN_NAME=devopsprocloud.in

echo -e "$Y Creating EC2 instances and updating Route 53 Records in AWS using Shell-Script$N"

# INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")

for i in "${INSTANCES[@]}"
do

  # Run instances and capture instance IDs
  INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[*].InstanceId' --output text)

  if [ $i == "web" ]
  then
    IP=$(aws ec2 describe-instances \
          --instance-ids $INSTANCE_ID \
          --query 'Reservations[].Instances[].PublicIpAddress' \
          --output text
      )
    RECORD_NAME="$i.$DOMAIN_NAME"
  else
    IP=$(aws ec2 describe-instances \
          --instance-ids $INSTANCE_ID \
          --query 'Reservations[].Instances[].PrivateIpAddress' \
          --output text
      )
  fi
    RECORD_NAME="$i.$DOMAIN_NAME"

  echo -e "$G $i$N: $B$IP$N"

  aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Creating Route 53 Record for '$i'",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'$IP'"
            }
          ]
        }
      }
    ]
  }
  '
done

