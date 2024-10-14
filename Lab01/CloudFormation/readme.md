# CloudFormation Templates for VPC and EC2 Instances

This repository contains AWS CloudFormation templates to set up a VPC with public and private subnets, and deploy EC2 instances in those subnets.

## Prerequisites

- AWS CLI installed and configured
- AWS CloudFormation permissions
- An existing EC2 KeyPair

## Files

- `CloudFormation/0-vpc.yml`: Creates a VPC with public and private subnets, route tables, and a NAT gateway.
- `CloudFormation/ec2.yml`: Deploys EC2 instances in the public and private subnets created by the VPC template.

## Usage

### Step 1: Create the VPC Stack

1. Navigate to the `CloudFormation` directory.
2. Run the following command to create the VPC stack:

    ```sh
    aws cloudformation create-stack --stack-name my-vpc-stack --template-body file://0-vpc.yml --capabilities CAPABILITY_NAMED_IAM
    ```

### Step 2: Create the EC2 Stack

1. After the VPC stack is created, run the following command to create the EC2 stack:

    ```sh
    aws cloudformation create-stack --stack-name my-ec2-stack --template-body file://ec2.yml --parameters ParameterKey=VPC,ParameterValue=<VPC_ID> ParameterKey=PublicSubnetID,ParameterValue=<PublicSubnetID> ParameterKey=PrivateSubnetID,ParameterValue=<PrivateSubnetID> ParameterKey=KeyName,ParameterValue=<YourKeyPairName>
    ```

   Replace `<VPC_ID>`, `<PublicSubnetID>`, `<PrivateSubnetID>`, and `<YourKeyPairName>` with the appropriate values from the outputs of the VPC stack.

## VPC diagram
