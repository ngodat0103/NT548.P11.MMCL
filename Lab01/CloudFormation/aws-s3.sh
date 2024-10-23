#!/bin/bash
set -e
#set -x

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null
    then
        echo "AWS CLI is not installed."
        read -p "Do you want to install AWS CLI? (y/n) [y]: " INSTALL_CHOICE
        INSTALL_CHOICE=${INSTALL_CHOICE:-y} # Default to 'y' if no input

        if [[ "$INSTALL_CHOICE" == "y" || "$INSTALL_CHOICE" == "Y" ]]; then
            # Automate AWS CLI installation based on the OS
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                sudo snap install aws-cli --classic
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                brew install awscli
            else
                echo "Unsupported OS. Please install AWS CLI manually."
                exit 1
            fi
            echo "AWS CLI installed successfully."
        else
            echo "Exiting. Please install AWS CLI manually."
            exit 1
        fi
    else
        echo "AWS CLI is already installed."
    fi
}

# Function to check if S3 bucket exists
check_bucket_exists() {
    if aws s3 ls "s3://$1"  2>&1 | grep -q 'NoSuchBucket'
    then
        echo "Bucket does not exist."
        read -r -p "Do you want to create the bucket? (y/n) [y]: " CREATE_CHOICE
        CREATE_CHOICE=${CREATE_CHOICE:-y} # Default to 'y' if no input

        if [[ "$CREATE_CHOICE" == "y" || "$CREATE_CHOICE" == "Y" ]]; then
            create_bucket "$1"
        else
            echo "Bucket creation aborted. Exiting."
            exit 1
        fi
    else
        echo "Bucket exists. Proceeding with file uploads."
    fi
}

# Function to create an S3 bucket
create_bucket() {
    read -r -p "Enter the AWS region for the new bucket [us-east-1]: " REGION
    REGION=${REGION:-us-east-1} # Default to 'us-east-1' if no input

    aws s3api create-bucket --bucket $1 --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
    if [[ $? -eq 0 ]]; then
        echo "Bucket $1 created successfully."
    else
        echo "Failed to create bucket $1."
        exit 1
    fi
}

DefaultBucketName="group7-bucket"
read -p "Enter your S3 bucket name [$DefaultBucketName]: " S3_BUCKET
S3_BUCKET=${S3_BUCKET:-$DefaultBucketName}
echo "S3_BUCKET: $S3_BUCKET"

# Check if AWS CLI is installed
check_aws_cli

# Verify if the bucket exists
check_bucket_exists "$S3_BUCKET"

# Upload .yaml files to S3 bucket using a loop
find module -name "*.yml" -exec aws s3 cp {} "s3://$S3_BUCKET" \; -exec echo "{} uploaded successfully." \;

echo "All .yaml files uploaded to S3 bucket."
