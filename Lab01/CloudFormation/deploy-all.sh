#!/bin/bash
set -x
# Default parameter values
DEFAULT_REGION="us-east-1"
DEFAULT_STACK_NAME_PREFIX="Group7"
DEFAULT_INSTANCE_TYPE="t3.small"

# Prompt user for input
read -p "Enter Stack Name (or 'default' for ${DEFAULT_STACK_NAME_PREFIX}): " STACK_NAME_PREFIX
read -p "Enter AWS Region (or 'default' for ${DEFAULT_REGION}): " REGION
read -p "Enter Instance Type (or 'default' for ${DEFAULT_INSTANCE_TYPE}): " INSTANCE_TYPE
read -p "Enter Base64 Private Key: " BASE64_PRIVATE_KEY

# Use default values if user inputs 'default'
STACK_NAME_PREFIX=${STACK_NAME_PREFIX:-$DEFAULT_STACK_NAME_PREFIX}
REGION=${REGION:-$DEFAULT_REGION}
INSTANCE_TYPE=${INSTANCE_TYPE:-$DEFAULT_INSTANCE_TYPE}

# Validate input
if [[ -z "$STACK_NAME_PREFIX" || -z "$REGION" || -z "$INSTANCE_TYPE" || -z "$BASE64_PRIVATE_KEY" ]]; then
    echo "Error: Missing required input. Exiting."
    exit 1
fi

# Function to deploy a stack and retrieve output
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

    # Retrieve stack outputs
    aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].Outputs"
}

# Deploy stacks in order
VPC_OUTPUT=$(deploy_stack "${STACK_NAME_PREFIX}-VPC" "0-VPC.yml" \
    ParameterKey=VPCName,ParameterValue="${STACK_NAME_PREFIX}-VPC")

SECURITY_OUTPUT=$(deploy_stack "${STACK_NAME_PREFIX}-Security" "1-security.yml" \
    ParameterKey=AllowSSHIP,ParameterValue="$ALLOW_SSH_IP" \
    ParameterKey=VPC,ParameterValue="${STACK_NAME_PREFIX}-VPC" \
    ParameterKey=PublicSubnetID,ParameterValue="$(echo "$VPC_OUTPUT" | jq -r '.[] | select(.OutputKey=="PublicSubnet0").OutputValue')")

deploy_stack "${STACK_NAME_PREFIX}-PublicRouteTable" "2-public-route-table.yaml" \
    ParameterKey=SubnetPublicId,ParameterValue="$(echo "$VPC_OUTPUT" | jq -r '.[] | select(.OutputKey=="PublicSubnet0").OutputValue')" \
    ParameterKey=VPCId,ParameterValue="${STACK_NAME_PREFIX}-VPC"

deploy_stack "${STACK_NAME_PREFIX}-PrivateRouteTable" "3-private-route-table.yaml" \
    ParameterKey=PrivateSubnetId,ParameterValue="$(echo "$VPC_OUTPUT" | jq -r '.[] | select(.OutputKey=="PrivateSubnet0").OutputValue')" \
    ParameterKey=VPCId,ParameterValue="${STACK_NAME_PREFIX}-VPC"

deploy_stack "${STACK_NAME_PREFIX}-EC2" "4-ec2.yml" \
    ParameterKey=Name,ParameterValue="${STACK_NAME_PREFIX}-EC2" \
    ParameterKey=sshPrivateKey,ParameterValue="$BASE64_PRIVATE_KEY" \
    ParameterKey=KeyName,ParameterValue="your-key-name" \
    ParameterKey=LatestAmiId,ParameterValue="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" \
    ParameterKey=PublicSubnetID,ParameterValue="$(echo "$VPC_OUTPUT" | jq -r '.[] | select(.OutputKey=="PublicSubnet0").OutputValue')" \
    ParameterKey=PrivateSubnetID,ParameterValue="$(echo "$VPC_OUTPUT" | jq -r '.[] | select(.OutputKey=="PrivateSubnet0").OutputValue')" \
    ParameterKey=SecurityGroupPublicInstanceID,ParameterValue="$(echo "$SECURITY_OUTPUT" | jq -r '.[] | select(.OutputKey=="SecurityGroupPublicInstance").OutputValue')" \
    ParameterKey=SecurityGroupPrivateInstanceID,ParameterValue="$(echo "$SECURITY_OUTPUT" | jq -r '.[] | select(.OutputKey=="SecurityGroupPrivateInstance").OutputValue')" \
    ParameterKey=InstanceType,ParameterValue="$INSTANCE_TYPE"

echo "All stacks deployed successfully."
