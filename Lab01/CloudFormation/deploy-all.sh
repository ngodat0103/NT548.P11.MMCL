#!/bin/bash

# Default parameter values
DEFAULT_REGION="us-east-1"
DEFAULT_STACK_NAME_PREFIX="Group7"
DEFAULT_ALLOW_SSH_IP="183.80.186.83/32"
DEFAULT_INSTANCE_TYPE="t3.small"

# Read parameters from command line or use default values
REGION=${1:-$DEFAULT_REGION}
STACK_NAME_PREFIX=${2:-$DEFAULT_STACK_NAME_PREFIX}
ALLOW_SSH_IP=${3:-$DEFAULT_ALLOW_SSH_IP}
INSTANCE_TYPE=${4:-$DEFAULT_INSTANCE_TYPE}

# Function to deploy a stack
deploy_stack() {
    local stack_name=$1
    local template_file=$2
    shift 2
    local parameters=("$@")

    echo "Deploying stack: $stack_name with template: $template_file"

    aws cloudformation create-stack \
        --region "$REGION" \
        --stack-name "$stack_name" \
        --template-body "file://$template_file" \
        --parameters "${parameters[@]}" \
        --capabilities CAPABILITY_NAMED_IAM

    echo "Waiting for stack $stack_name to be created..."
    aws cloudformation wait stack-create-complete --region "$REGION" --stack-name "$stack_name"
    echo "Stack $stack_name created successfully."
}

# Deploy stacks in order
deploy_stack "${STACK_NAME_PREFIX}-VPC" "0-VPC.yml" \
    ParameterKey=VPCName,ParameterValue="${STACK_NAME_PREFIX}-VPC"

deploy_stack "${STACK_NAME_PREFIX}-Security" "1-security.yml" \
    ParameterKey=AllowSSHIP,ParameterValue="$ALLOW_SSH_IP" \
    ParameterKey=VPC,ParameterValue="${STACK_NAME_PREFIX}-VPC" \
    ParameterKey=PublicSubnetID,ParameterValue="${STACK_NAME_PREFIX}-PublicSubnet0"

deploy_stack "${STACK_NAME_PREFIX}-PublicRouteTable" "2-public-route-table.yaml" \
    ParameterKey=SubnetPublicId,ParameterValue="${STACK_NAME_PREFIX}-PublicSubnet0" \
    ParameterKey=VPCId,ParameterValue="${STACK_NAME_PREFIX}-VPC"

deploy_stack "${STACK_NAME_PREFIX}-PrivateRouteTable" "3-private-route-table.yaml" \
    ParameterKey=PrivateSubnetId,ParameterValue="${STACK_NAME_PREFIX}-PrivateSubnet0" \
    ParameterKey=VPCId,ParameterValue="${STACK_NAME_PREFIX}-VPC"

deploy_stack "${STACK_NAME_PREFIX}-EC2" "4-ec2.yml" \
    ParameterKey=Name,ParameterValue="${STACK_NAME_PREFIX}-EC2" \
    ParameterKey=sshPrivateKey,ParameterValue="your-ssh-private-key" \
    ParameterKey=KeyName,ParameterValue="your-key-name" \
    ParameterKey=LatestAmiId,ParameterValue="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" \
    ParameterKey=PublicSubnetID,ParameterValue="${STACK_NAME_PREFIX}-PublicSubnet0" \
    ParameterKey=PrivateSubnetID,ParameterValue="${STACK_NAME_PREFIX}-PrivateSubnet0" \
    ParameterKey=SecurityGroupPublicInstanceID,ParameterValue="${STACK_NAME_PREFIX}-SecurityGroupPublicInstance" \
    ParameterKey=SecurityGroupPrivateInstanceID,ParameterValue="${STACK_NAME_PREFIX}-SecurityGroupPrivateInstance" \
    ParameterKey=InstanceType,ParameterValue="$INSTANCE_TYPE"

echo "All stacks deployed successfully."
