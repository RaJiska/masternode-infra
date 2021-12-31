#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`

# Mount Data Volume
mount /dev/xvdb /mnt

# Associate Global EIP to this Instance
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id -H "X-aws-ec2-metadata-token: $TOKEN"`
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ALLOCATION_ID} --allow-reassociation --region ${REGION}