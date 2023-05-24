#!/bin/bash

# IMPORTANT -
# Set the name of your key-pair before running the script
# Alternativelay uncomment line 7 and 8 to create a new key pair
KEY_PAIR_NAME="Please set the name of your key-pair"
# aws ec2 create-key-pair --key-name DanielHwKeyPair --query 'KeyMaterial' --output text > DanielHwKeyPair.pem
# KEY_PAIR_NAME="DanielHwKeyPair"

####################################################
        #  PART 1 - Set up AWS EC2 instance
####################################################
echo "Setting up AWS EC2 instance..."

# We first create a security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name HwSecurityGroup --description "Security Group for Cloud Computing HW1" --output text --query 'GroupId')
# Add inbound rule for HTTP
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
# Add inbound rule for HTTPS
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0

echo "Security group created with ID: $SECURITY_GROUP_ID"

# Set AWS region and instance details
AWS_REGION="eu-central-1" # Europe (Frankfurt) is a region near Israel
AMI_ID = "ami-04e601abe3e1a910f" # Free tier unbuntu 22.04 LTS
INSTANCE_TYPE="t2.micro"

# Launch the EC2 instance
instance_info=$(aws ec2 run-instances \
  --region $AWS_REGION \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --security-group-ids $SECURITY_GROUP_ID \
  --key-name $KEY_PAIR_NAME \
  --output json)

# Extract the instance ID from the response
instance_id=$(echo $instance_info | jq -r '.Instances[0].InstanceId')

# Wait for the instance to be running
aws ec2 wait instance-running --region $AWS_REGION --instance-ids $instance_id

# Retrieve the public DNS name of the instance
public_dns=$(aws ec2 describe-instances \
  --region $AWS_REGION \
  --instance-ids $instance_id \
  --query "Reservations[0].Instances[0].PublicDnsName" \
  --output text)

##########################################################################
    #  PART 2 - Output the URL of the live website
    #           (which is the public IP of the server)
##########################################################################
echo "URL of the live server: http://$public_dns"
echo "The script setup-project.sh at the racine of the project (/var/www/html/hw1-cloud-computing/) must be run via ssh to install the project and necessary packages."
echo "URL of the working site created on the student aws account: http://3.120.209.17"