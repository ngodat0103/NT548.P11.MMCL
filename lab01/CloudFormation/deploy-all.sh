#!/bin/bash
#set -x
# Default values
DEFAULT_BUCKET_NAME="group7-bucket"
DEFAULT_INSTANCE_TYPE="t3.medium"
DEFAULT_LATEST_AMI_ID="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
DEFAULT_KEY_NAME="vockey"
ROOT_STACK_NAME="Lab01"
DEFAULT_ALLOW_SSH_CIDR="118.68.53.42/32"

# Function to prompt the user for input with a default value
prompt() {
  read -p "$1 [$2]: " input
  echo "${input:-$2}"
}

# Prompt user for input
bucket_name=$(prompt "Enter S3 bucket name" "$DEFAULT_BUCKET_NAME")
ssh_private_key=$(prompt "Enter SSH private key (in PEM format using base64 encoded)" "")
key_name=$(prompt "Enter EC2 KeyPair name" "$DEFAULT_KEY_NAME")
latest_ami_id=$(prompt "Enter latest AMI ID" "$DEFAULT_LATEST_AMI_ID")
instance_type=$(prompt "Enter EC2 instance type" "$DEFAULT_INSTANCE_TYPE")
allow_ssh_cidr=$(prompt "Enter CIDR block to allow SSH access" "$DEFAULT_ALLOW_SSH_CIDR")

# Check if required values are provided
if [ -z "$ssh_private_key" ]; then
  echo "Error: SSH private key is required."
  exit 1
fi

if [ -z "$key_name" ]; then
  echo "Error: EC2 KeyPair name is required."
  exit 1
fi

# Deploy the root stack that contains all nested stacks
echo "Deploying root CloudFormation stack with nested stacks..."
aws cloudformation create-stack \
  --stack-name "$ROOT_STACK_NAME" \
  --template-body file://main.yml \
  --parameters ParameterKey=BucketName,ParameterValue="$bucket_name" \
               ParameterKey=sshPrivateKey,ParameterValue="$ssh_private_key" \
               ParameterKey=KeyName,ParameterValue="$key_name" \
               ParameterKey=LatestAmiId,ParameterValue="$latest_ami_id" \
               ParameterKey=InstanceType,ParameterValue="$instance_type" \
               ParameterKey=AllowSSHIP,ParameterValue="$allow_ssh_cidr" \
  --capabilities CAPABILITY_NAMED_IAM

# Function to watch the stack creation progress
watch_stack() {
  stack_name=$1
  while true; do
    # Get the current status of the stack
    stack_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text)

    # Output the current status
    echo "Current status of $stack_name: $stack_status"

    # Check if the stack creation is complete or failed
    if [[ "$stack_status" == "CREATE_COMPLETE" ]]; then
      echo "Stack $stack_name created successfully."
      break
    elif [[ "$stack_status" == "ROLLBACK_COMPLETE" || "$stack_status" == "CREATE_FAILED" ]]; then
      echo "Stack $stack_name creation failed."
      exit 1
    fi

    sleep 10
  done
}

# Watch the root stack status until completion
echo "Monitoring stack creation status..."
watch_stack "$ROOT_STACK_NAME"

echo "All resources have been successfully created!"
