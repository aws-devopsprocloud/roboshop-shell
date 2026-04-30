#!/bin/bash 

export AWS_PAGER=""

AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-073d40ac23ccdcec7
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
ZONE_ID=Z059178135GSKTAXVUIAQ

for i in ${INSTANCES[@]}
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then 
        INSTANCE_TYPE="t3.small"
    else 
        INSTANCE_TYPE="t3.micro"
    fi
    IP_ADDRESS=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INSTANCE_TYPE \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance, Tags=[{Key=Name, Value=$i}]")
    
done

echo "INSTANCE: $i"

#Route 53 Records
# aws route53 change-resource-record-sets \
#   --hosted-zone-id $ZONE_ID \
#   --change-batch file://<(cat <<EOF
# {
#   "Comment": "Creating Route 53 Record for $i",
#   "Changes": [
#     {
#       "Action": "UPSERT",
#       "ResourceRecordSet": {
#         "Name": "$i.devopsprocloud.in",
#         "Type": "A",
#         "TTL": 1,
#         "ResourceRecords": [
#           {
#             "Value": "$RECORD_VALUE"
#           }
#         ]
#       }
#     }
#   ]
# }
# EOF
# ) > /dev/null 2>&1

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Creating a record set for cognito endpoint"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "$i.devopsprocloud.in"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP_ADDRESS'"
        }]
      }
    }]
  }'